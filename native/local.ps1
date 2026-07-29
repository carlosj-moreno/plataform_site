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

    # Threads de waitress = techo de concurrencia real del backend (cada uno
    # atiende una request Django a la vez). El default de waitress (4) y el 8
    # anterior se saturaban con ~40 usuarios activos por el polling de la Bandeja.
    # Configurable en deploy.config.ps1; 16 es un default holgado.
    if (-not (Get-Variable -Name BackendThreads -ValueOnly -ErrorAction SilentlyContinue)) { $BackendThreads = 16 }
    $b = Start-Process -FilePath $waitress `
        -ArgumentList "--listen=127.0.0.1:$BackendPort", "--threads=$BackendThreads", "core.wsgi:application" `
        -WorkingDirectory $Backend -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput "$LogDir\backend.out" -RedirectStandardError "$LogDir\backend.err"

    # Recuperar fotos ANTIGUAS sueltas: al arrancar, barrer el histórico y
    # adjuntar a su carro las fotos que quedaron en el chat sin asignarse (server
    # caído, ráfaga desordenada, etc.) — "hay carros que no toma las fotos".
    # Usa la MISMA lógica probada del "Auto-clasificar" (secciona por placa para
    # no mezclar carros). Corre en segundo plano para no demorar el arranque.
    # Se puede saltar con:  $env:SKIP_VEHICLE_BACKFILL = "1"
    if ($env:SKIP_VEHICLE_BACKFILL -ne "1") {
        $py0 = Join-Path $Backend ".venv\Scripts\python.exe"
        if (-not (Test-Path $py0)) { $py0 = "python" }
        Write-Host "Recuperando fotos antiguas de vehiculos (segundo plano)..." -ForegroundColor Cyan
        Start-Process -FilePath $py0 `
            -ArgumentList "manage.py", "retomar_fotos_vehiculos", "--apply" `
            -WorkingDirectory $Backend -WindowStyle Hidden `
            -RedirectStandardOutput "$LogDir\vehicle-backfill.out" `
            -RedirectStandardError  "$LogDir\vehicle-backfill.err" | Out-Null
    }

    # Puentes de WhatsApp: deben estar conectados en UNA sola máquina (el
    # SERVIDOR). Con el engine vinculado también aquí, cada mensaje se procesa
    # y se PAGA doble (2026-07-29: día de ~$11 en Together por la duplicación).
    # $env:SKIP_ENGINE = "1" arranca el stack SIN engine para desarrollo local.
    $e = $null
    if ($env:SKIP_ENGINE -ne "1") {
        $env:ENGINE_SECRET = Get-EnvValue "WHATSAPP_ENGINE_SECRET"
        $env:PORT = "$EnginePort"
        $env:DJANGO_URL = "http://127.0.0.1:$BackendPort"
        $e = Start-Process -FilePath "node" -ArgumentList "app.js" `
            -WorkingDirectory (Join-Path $Front "engine") -WindowStyle Hidden -PassThru `
            -RedirectStandardOutput "$LogDir\engine.out" -RedirectStandardError "$LogDir\engine.err"
    } else {
        Write-Host "   SKIP_ENGINE=1: engine NO arrancado (los puentes viven en el servidor)." -ForegroundColor DarkYellow
    }

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

    $eid = if ($e) { $e.Id } else { "-" }
    "$($b.Id) backend-waitress`n$(if ($e) { "$($e.Id) engine-node`n" })$($f.Id) frontend-vite" | Out-File $PidFile
    Write-Host ("Arrancado -> backend={0} engine={1} frontend={2}" -f $b.Id, $eid, $f.Id) -ForegroundColor Green
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
    # Engines huérfanos de arranques anteriores: pids.txt solo recuerda el ÚLTIMO
    # arranque, así que un start sin stop dejaba engines viejos vivos. Varios
    # engines sobre el mismo perfil de Chrome se matan el navegador entre sí y
    # la línea de WhatsApp se cae en bucle. Se barren por línea de comandos
    # ("node app.js" es el engine; los vite/npm no matchean).
    Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
        Where-Object { $_.CommandLine -match '(^|\s)"?app\.js"?\s*$' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    # Y los Chrome del engine que hayan quedado agarrando el perfil de sesión:
    Get-CimInstance Win32_Process |
        Where-Object { $_.Name -match 'chrome' -and $_.CommandLine -match 'session-conn_' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
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
