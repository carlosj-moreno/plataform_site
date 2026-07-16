# ─────────────────────────────────────────────────────────────────────────────
# deploy.ps1 — Prepara y ejecuta BootWhatsapp en LOCAL (sin Docker, sin Caddy,
# sin servicios, SIN instalar software de terceros).
#
# Solo usa lo que ya está instalado (git, Node, Python) para:
#   1. Clonar/actualizar Backend/ y Frontend/ desde sus repos privados.
#   2. Copiar el .env (secretos) a Backend\bootwhatsapp\.env (lo lee Django).
#   3. Backend  : venv + pip (waitress/whitenoise) + migrate + collectstatic
#      Engine   : npm ci
#      Frontend : npm ci + vite build  (apuntando al backend en el puerto elegido)
#   4. Arranca los 3 procesos con native\local.ps1 (puertos en deploy.config.ps1).
#
# UN SOLO COMANDO: doble clic en instalar.bat  (o)
#   powershell -ExecutionPolicy Bypass -File .\deploy.ps1
# La 1ª vez crea deploy.config.ps1 y .env (desde los .example) y los abre.
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot
$Repo = $PSScriptRoot

function Get-EnvValue($file, $key) {
    $m = Select-String -Path $file -Pattern "^\s*$([regex]::Escape($key))\s*=(.*)$" | Select-Object -First 1
    if (-not $m) { return $null }
    return (($m.Matches[0].Groups[1].Value -replace '\s+#.*$', '').Trim())
}

# ── 0. Bootstrap: crear config/.env si faltan ────────────────────────────────
$bootstrapped = $false
if (-not (Test-Path ".\deploy.config.ps1")) {
    Copy-Item ".\deploy.config.example.ps1" ".\deploy.config.ps1"
    Write-Host "+ Cree deploy.config.ps1 (repos/branch/token/puertos)." -ForegroundColor Yellow
    $bootstrapped = $true
}
if (-not (Test-Path ".\.env")) {
    Copy-Item ".\.env.native.example" ".\.env"
    Write-Host "+ Cree .env (secretos)." -ForegroundColor Yellow
    $bootstrapped = $true
}
if ($bootstrapped) {
    Write-Host ""
    Write-Host "PRIMER PASO: completa los archivos que abri y vuelve a ejecutar (instalar.bat)." -ForegroundColor Cyan
    Start-Process notepad ".\.env"              | Out-Null
    Start-Process notepad ".\deploy.config.ps1" | Out-Null
    exit 0
}

# ── 1. Cargar configuración ──────────────────────────────────────────────────
. .\deploy.config.ps1
foreach ($v in "BackendRepo","FrontendRepo","BackendBranch","FrontendBranch","BackendDir","FrontendDir") {
    if (-not (Get-Variable -Name $v -ValueOnly -ErrorAction SilentlyContinue)) {
        Write-Host "X Falta `$$v en deploy.config.ps1" -ForegroundColor Red; exit 1
    }
}
if (-not (Get-Variable -Name BackendPort  -ValueOnly -ErrorAction SilentlyContinue)) { $BackendPort  = 8000 }
if (-not (Get-Variable -Name FrontendPort -ValueOnly -ErrorAction SilentlyContinue)) { $FrontendPort = 8080 }
if (-not (Get-Variable -Name ServerHost   -ValueOnly -ErrorAction SilentlyContinue)) { $ServerHost   = "localhost" }
if ($SshKey) { $env:GIT_SSH_COMMAND = "ssh -i `"$SshKey`" -o IdentitiesOnly=yes" }
if (-not (Get-Variable -Name GitHubToken -ValueOnly -ErrorAction SilentlyContinue)) { $GitHubToken = "" }

# Auth de git sin embeber el PAT en la URL (auditoría B5). Antes se inyectaba
# `https://x-access-token:$token@github.com/...`, dejando el token dentro de la
# URL del remote y en cada `git fetch` (visible en args de proceso / logs). En su
# lugar pasamos el token como cabecera Authorization efímera por-comando vía
# `-c http.extraHeader=...`: nunca se persiste en el remote ni en la config.
function Get-GitAuthArgs($url) {
    if ($GitHubToken -and $url -like "https://*") {
        $basic = [Convert]::ToBase64String(
            [Text.Encoding]::ASCII.GetBytes("x-access-token:$GitHubToken"))
        return @('-c', "http.extraHeader=Authorization: Basic $basic")
    }
    return @()
}

$BackendPath  = Join-Path $Repo $BackendDir
$FrontendPath = Join-Path $Repo $FrontendDir
$EnginePath   = Join-Path $FrontendPath "engine"

# Aviso de secretos OBLIGATORIOS vacíos
$missing = @()
foreach ($k in "SECRET_KEY","DB_PASSWORD","WHATSAPP_API_TOKEN","WHATSAPP_PHONE_NUMBER_ID","WHATSAPP_APP_SECRET","META_VERIFY_TOKEN","GROQ_API_KEY","FERNET_KEY","WHATSAPP_ENGINE_SECRET") {
    if (-not (Get-EnvValue ".\.env" $k)) { $missing += $k }
}
if ($missing.Count -gt 0) {
    Write-Host "X Faltan secretos OBLIGATORIOS en .env:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
    Start-Process notepad ".\.env" | Out-Null
    exit 1
}

# ── 2. Comprobar herramientas (NO se instala nada; solo se avisa si falta) ────
foreach ($tool in "git","node","npm") {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "X Falta '$tool' en el PATH. Instálalo y reintenta (no instalo software por ti)." -ForegroundColor Red
        exit 1
    }
}
function Get-PythonCmd {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        & py -3.14 -c "print(1)" *> $null
        if ($LASTEXITCODE -eq 0) { return , @("py", "-3.14") }
        return , @("py")
    }
    if (Get-Command python -ErrorAction SilentlyContinue) { return , @("python") }
    Write-Host "X Falta Python (py / python) en el PATH. Instálalo y reintenta." -ForegroundColor Red
    exit 1
}
$PyCmd = Get-PythonCmd; $PyExe = $PyCmd[0]; $PyArgs = @($PyCmd[1..($PyCmd.Count - 1)])

# Aviso si PostgreSQL no responde (no es fatal: el migrate dará el error real)
$dbHost = (Get-EnvValue ".\.env" "DB_HOST"); if (-not $dbHost) { $dbHost = "localhost" }
$dbPort = (Get-EnvValue ".\.env" "DB_PORT"); if (-not $dbPort) { $dbPort = "5432" }
try { $t = New-Object Net.Sockets.TcpClient; $t.Connect($dbHost, [int]$dbPort); $t.Close() }
catch { Write-Host "!! PostgreSQL no responde en ${dbHost}:${dbPort} (instálalo/arráncalo y crea la BD)." -ForegroundColor Yellow }

# ── 3. Parar el stack si estaba corriendo (evita locks al reconstruir) ────────
if (Test-Path ".\native\local.ps1") {
    try { & powershell -ExecutionPolicy Bypass -File .\native\local.ps1 stop *> $null } catch {}
}

# ── 4. Clonar/actualizar los repos privados ──────────────────────────────────
function Sync-Repo($repo, $branch, $dir) {
    $authArgs = Get-GitAuthArgs $repo
    if (Test-Path (Join-Path $dir ".git")) {
        Write-Host "-> Actualizando $dir ($branch)..." -ForegroundColor Cyan
        git @authArgs -C $dir fetch --depth 1 $repo $branch
        if ($LASTEXITCODE -ne 0) { throw "git fetch fallo para $dir" }
        git -C $dir checkout -B $branch FETCH_HEAD
    } else {
        Write-Host "-> Clonando $repo -> $dir ($branch)..." -ForegroundColor Cyan
        if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
        git @authArgs clone --depth 1 --branch $branch $repo $dir
        if ($LASTEXITCODE -ne 0) { throw "git clone fallo para $dir" }
    }
    if ($LASTEXITCODE -ne 0) { throw "git fallo para $dir" }
}
Sync-Repo $BackendRepo  $BackendBranch  $BackendDir
Sync-Repo $FrontendRepo $FrontendBranch $FrontendDir

# ── 5. Colocar el .env donde Django lo lee ───────────────────────────────────
Copy-Item ".\.env" (Join-Path $BackendPath ".env") -Force
Write-Host "-> .env copiado a $BackendDir\.env" -ForegroundColor DarkGray
if (Select-String -Path ".\.env" -Pattern "^\s*DB_HOST\s*=\s*host\.docker\.internal" -Quiet) {
    Write-Host "!! DB_HOST=host.docker.internal no resuelve sin Docker. Ponlo en localhost." -ForegroundColor Yellow
}

# ── 6. Backend: venv + deps + migraciones + estáticos ────────────────────────
Write-Host "-> Backend: venv + dependencias..." -ForegroundColor Cyan
$VenvPy = Join-Path $BackendPath ".venv\Scripts\python.exe"
if (-not (Test-Path $VenvPy)) {
    & $PyExe @PyArgs -m venv (Join-Path $BackendPath ".venv")
    if ($LASTEXITCODE -ne 0) { throw "No se pudo crear el venv." }
}
& $VenvPy -m pip install --upgrade pip -q
& $VenvPy -m pip install -r (Join-Path $BackendPath "requirements.txt") -q
if ($LASTEXITCODE -ne 0) { throw "pip install -r requirements.txt fallo." }
& $VenvPy -m pip install "waitress==3.0.2" "whitenoise==6.12.0" "cryptography>=46.0" -q
if ($LASTEXITCODE -ne 0) { throw "pip install de extras fallo." }
Push-Location $BackendPath
try {
    & $VenvPy manage.py migrate --noinput
    if ($LASTEXITCODE -ne 0) { throw "migrate fallo." }
    & $VenvPy manage.py collectstatic --noinput
    if ($LASTEXITCODE -ne 0) { throw "collectstatic fallo." }
} finally { Pop-Location }

# ── 7. Engine: deps de Node ──────────────────────────────────────────────────
Write-Host "-> Engine: npm ci..." -ForegroundColor Cyan
Push-Location $EnginePath
try { npm ci; if ($LASTEXITCODE -ne 0) { throw "npm ci (engine) fallo." } } finally { Pop-Location }

# ── 8. Frontend: build de Vite (mismo origen via native\serve.py) ────────────
# API y /media salen relativos: serve.py (puerto del frontend) los reenvia al
# backend. Asi funciona desde cualquier maquina que abra http://host:FrontendPort
Write-Host "-> Frontend: npm ci + build (API = /api, mismo origen)..." -ForegroundColor Cyan
$env:VITE_API_URL          = "/api"
$env:VITE_WS_URL           = ""
$env:VITE_POLLING_INTERVAL = "5000"
$env:VITE_APP_ENV          = "production"
Push-Location $FrontendPath
try {
    npm ci
    if ($LASTEXITCODE -ne 0) { throw "npm ci (frontend) fallo." }
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "vite build fallo." }
} finally { Pop-Location }

# ── 9. Arrancar el stack en local ────────────────────────────────────────────
& powershell -ExecutionPolicy Bypass -File .\native\local.ps1 start

Write-Host ""
Write-Host "OK Listo. Abre http://localhost:$FrontendPort" -ForegroundColor Green
Write-Host "   Manejo: .\native\local.ps1 status | stop | start   |   Logs: .\logs\*.err"
