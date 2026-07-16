# ─────────────────────────────────────────────────────────────────────────────
# local.ps1 — Arranca/para el stack en LOCAL (sin Docker, sin Caddy, sin servicios).
#
#   Frontend (vite preview)   -> http://localhost:8080
#   Backend  (waitress/Django)-> http://localhost:8000   (el front le pega directo)
#   Engine   (node)           -> http://127.0.0.1:3001
#
# Uso:
#   .\native\local.ps1 start
#   .\native\local.ps1 stop
#   .\native\local.ps1 status
# ─────────────────────────────────────────────────────────────────────────────
param(
    [Parameter(Position = 0)]
    [ValidateSet("start", "stop", "status")]
    [string]$Action = "status"
)
$ErrorActionPreference = "Stop"
$Repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$LogDir  = Join-Path $Repo "logs"
$PidFile = Join-Path $LogDir "pids.txt"
$Backend = Join-Path $Repo "Backend\bootwhatsapp"
$Front   = Join-Path $Repo "Frontend\bootwhatsapp_frontend"

# Puertos (asignables en deploy.config.ps1)
if (Test-Path (Join-Path $Repo "deploy.config.ps1")) { . (Join-Path $Repo "deploy.config.ps1") }
if (-not (Get-Variable -Name BackendPort  -ValueOnly -ErrorAction SilentlyContinue)) { $BackendPort  = 8000 }
if (-not (Get-Variable -Name FrontendPort -ValueOnly -ErrorAction SilentlyContinue)) { $FrontendPort = 8080 }
if (-not (Get-Variable -Name EnginePort   -ValueOnly -ErrorAction SilentlyContinue)) { $EnginePort   = 3001 }
if (-not (Get-Variable -Name ServerHost   -ValueOnly -ErrorAction SilentlyContinue)) { $ServerHost   = "localhost" }

function Get-EnvValue($key) {
    $m = Select-String -Path (Join-Path $Repo ".env") -Pattern "^\s*$([regex]::Escape($key))\s*=(.*)$" | Select-Object -First 1
    if (-not $m) { return $null }
    return (($m.Matches[0].Groups[1].Value -replace '\s+#.*$', '').Trim())
}

function Start-Stack {
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    $waitress = Join-Path $Backend ".venv\Scripts\waitress-serve.exe"
    if (-not (Test-Path $waitress)) { throw "Falta el venv del backend. Corre .\deploy.ps1 primero." }

    # Reconstruir el frontend para servir SIEMPRE el codigo actual. Antes habia
    # que acordarse de buildear a mano y por eso "no se veian los cambios".
    # Se puede saltar con:  $env:SKIP_FRONTEND_BUILD = "1"
    if ($env:SKIP_FRONTEND_BUILD -ne "1") {
        Write-Host "Construyendo frontend (dist)..." -ForegroundColor Cyan
        Push-Location $Front
        try {
            & npm run build *> "$LogDir\frontend-build.out"
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  Build FALLO -> sirvo el dist anterior. Ver logs\frontend-build.out" -ForegroundColor Yellow
            } else {
                Write-Host "  Frontend reconstruido." -ForegroundColor Green
            }
        } catch {
            Write-Host "  No se pudo correr 'npm run build' ($_). Sirvo el dist anterior." -ForegroundColor Yellow
        } finally {
            Pop-Location
        }
    }

    # CORS/CSRF: permitir el origen del frontend (segun los puertos configurados).
    # load_dotenv no pisa el env del proceso, asi que esto manda sobre el .env.
    $origins = "http://${ServerHost}:${FrontendPort},http://localhost:${FrontendPort},http://127.0.0.1:${FrontendPort}"
    $env:CORS_ALLOWED_ORIGINS  = $origins
    $env:CSRF_TRUSTED_ORIGINS  = $origins

    $b = Start-Process -FilePath $waitress `
        -ArgumentList "--listen=127.0.0.1:$BackendPort", "core.wsgi:application" `
        -WorkingDirectory $Backend -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput "$LogDir\backend.out" -RedirectStandardError "$LogDir\backend.err"

    $env:ENGINE_SECRET = Get-EnvValue "WHATSAPP_ENGINE_SECRET"
    $env:PORT = "$EnginePort"
    $env:DJANGO_URL = "http://127.0.0.1:$BackendPort"
    $e = Start-Process -FilePath "node" -ArgumentList "app.js" `
        -WorkingDirectory (Join-Path $Front "engine") -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput "$LogDir\engine.out" -RedirectStandardError "$LogDir\engine.err"

    # Frontend = servidor Python (stdlib): sirve dist\ y reenvia /api,/media,/static,/webhook
    # al backend. Mismo origen -> los documentos (/media) cargan sin proxy externo.
    $py = Join-Path $Backend ".venv\Scripts\python.exe"
    if (-not (Test-Path $py)) { $py = "python" }

    # Coherencia TLS (auditoria M3): el proxy solo debe anunciar X-Forwarded-Proto:
    # https cuando el trafico REALMENTE llega por TLS (tunel/Caddy/nginx delante).
    # Si ENABLE_HTTPS no esta activo, el proxy sirve HTTP plano en la LAN, asi que
    # anunciar "https" haria que Django emitiera cookies Secure/HSTS sobre HTTP.
    # Derivamos el proto del .env en vez de hardcodear "https".
    $enableHttps = (Get-EnvValue "ENABLE_HTTPS")
    $fwdProto = if ($enableHttps -eq "True") { "https" } else { "http" }
    if ($fwdProto -eq "http") {
        Write-Host "   TLS off (ENABLE_HTTPS!=True): proxy anuncia http. Expon solo por tunel/proxy TLS." -ForegroundColor DarkYellow
    }

    $f = Start-Process -FilePath $py `
        -ArgumentList "$Repo\native\serve.py", "--port", "$FrontendPort", "--host", "0.0.0.0", "--backend", "127.0.0.1:$BackendPort", "--dist", "$Front\dist", "--forwarded-proto", "$fwdProto" `
        -WorkingDirectory $Repo -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput "$LogDir\frontend.out" -RedirectStandardError "$LogDir\frontend.err"

    "$($b.Id) backend-waitress`n$($e.Id) engine-node`n$($f.Id) frontend-vite" | Out-File $PidFile
    Write-Host ("Arrancado -> backend={0} engine={1} frontend={2}" -f $b.Id, $e.Id, $f.Id) -ForegroundColor Green
    Write-Host "   Abre: http://localhost:$FrontendPort   |   Logs: logs\*.out / *.err"
}

function Stop-Stack {
    if (Test-Path $PidFile) {
        foreach ($line in (Get-Content $PidFile)) {
            $id = ($line -split '\s+')[0]
            if ($id -match '^\d+$') { Stop-Process -Id ([int]$id) -Force -ErrorAction SilentlyContinue }
        }
    }
    # Por si quedó algún waitress huérfano:
    Get-Process waitress-serve -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "Detenido." -ForegroundColor Yellow
}

function Show-Status {
    foreach ($p in @(@{n="Frontend";port=$FrontendPort}, @{n="Backend";port=$BackendPort}, @{n="Engine";port=$EnginePort})) {
        $up = Test-NetConnection localhost -Port $p.port -InformationLevel Quiet -WarningAction SilentlyContinue
        $c = if ($up) { "Green" } else { "Red" }
        Write-Host ("  {0,-9} :{1}  {2}" -f $p.n, $p.port, $(if ($up) { "UP" } else { "DOWN" })) -ForegroundColor $c
    }
}

switch ($Action) {
    "start"  { Start-Stack }
    "stop"   { Stop-Stack }
    "status" { Show-Status }
}
