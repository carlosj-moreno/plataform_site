# ─────────────────────────────────────────────────────────────────────────────
# services.ps1 — Gestiona los 3 servicios de Windows (NSSM) del stack nativo.
#
#   bootwa-backend  → waitress  (Django)   127.0.0.1:8000
#   bootwa-engine   → node app.js (WhatsApp QR) 127.0.0.1:3001
#   bootwa-proxy    → caddy (SPA + reverse-proxy)  0.0.0.0:8080
#
# Uso (PowerShell como Administrador — registrar/borrar servicios lo requiere):
#   .\native\services.ps1 install     # (re)registra los 3 servicios y arranca
#   .\native\services.ps1 start
#   .\native\services.ps1 stop
#   .\native\services.ps1 restart
#   .\native\services.ps1 status
#   .\native\services.ps1 uninstall   # borra los 3 servicios
# ─────────────────────────────────────────────────────────────────────────────
param(
    [Parameter(Position = 0)]
    [ValidateSet("install", "uninstall", "start", "stop", "restart", "status")]
    [string]$Action = "status"
)

$ErrorActionPreference = "Stop"

# Raíz del repo = carpeta padre de native\
$Repo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $Repo

# ── Configuración (rutas de repos, NodePath, PostgresServiceName opcionales) ──
if (-not (Test-Path ".\deploy.config.ps1")) {
    Write-Host "X Falta deploy.config.ps1 (Copy-Item deploy.config.example.ps1 deploy.config.ps1)" -ForegroundColor Red
    exit 1
}
. .\deploy.config.ps1
if (-not $BackendDir)  { $BackendDir  = "Backend/bootwhatsapp" }
if (-not $FrontendDir) { $FrontendDir = "Frontend/bootwhatsapp_frontend" }
if (-not (Get-Variable -Name NodePath -ValueOnly -ErrorAction SilentlyContinue))            { $NodePath = "" }
if (-not (Get-Variable -Name PostgresServiceName -ValueOnly -ErrorAction SilentlyContinue)) { $PostgresServiceName = "" }

# ── Resolver herramientas ────────────────────────────────────────────────────
$Nssm = Join-Path $Repo "bin\nssm.exe"
if (-not (Test-Path $Nssm)) {
    $cmd = Get-Command nssm.exe -ErrorAction SilentlyContinue
    if ($cmd) { $Nssm = $cmd.Source }
    else {
        Write-Host "X No se encontró nssm.exe (bin\nssm.exe ni en PATH). Ejecuta: .\native\get-tools.ps1" -ForegroundColor Red
        exit 1
    }
}

function Get-EnvValue($file, $key) {
    if (-not (Test-Path $file)) { return $null }
    foreach ($line in Get-Content $file) {
        if ($line -match "^\s*$([regex]::Escape($key))\s*=\s*(.*)$") { return $matches[1].Trim() }
    }
    return $null
}

function Resolve-NodePath {
    if ($NodePath -and (Test-Path $NodePath)) { return $NodePath }
    $cmd = Get-Command node.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    throw "No se encontró node.exe (define `$NodePath en deploy.config.ps1 o agrégalo al PATH)."
}

# ── Definición de los servicios ──────────────────────────────────────────────
$LogDir = Join-Path $Repo "logs"

$EngineSecret = Get-EnvValue (Join-Path $Repo ".env") "WHATSAPP_ENGINE_SECRET"
$CaddyCfg     = Join-Path $Repo "Caddyfile"

function Get-Services {
    @(
        [ordered]@{
            Name = "bootwa-backend"
            Exe  = Join-Path $Repo "$BackendDir\.venv\Scripts\waitress-serve.exe"
            Args = "--listen=127.0.0.1:8000 core.wsgi:application"
            Dir  = Join-Path $Repo $BackendDir
            Env  = @()
        },
        [ordered]@{
            Name = "bootwa-engine"
            Exe  = (Resolve-NodePath)
            Args = "app.js"
            Dir  = Join-Path $Repo "$FrontendDir\engine"
            Env  = @("ENGINE_SECRET=$EngineSecret", "PORT=3001", "DJANGO_URL=http://127.0.0.1:8000")
        },
        [ordered]@{
            Name = "bootwa-proxy"
            Exe  = Join-Path $Repo "bin\caddy.exe"
            Args = 'run --config "' + $CaddyCfg + '" --adapter caddyfile'
            Dir  = $Repo
            Env  = @()
        }
    )
}

function Test-ServiceExists($name) {
    return [bool](Get-Service -Name $name -ErrorAction SilentlyContinue)
}

function Remove-OneService($name) {
    if (Test-ServiceExists $name) {
        & $Nssm stop $name 2>$null | Out-Null
        & $Nssm remove $name confirm | Out-Null
        Write-Host "  - borrado $name" -ForegroundColor DarkGray
    }
}

function Install-Services {
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

    if (-not $EngineSecret) {
        Write-Host "X WHATSAPP_ENGINE_SECRET no esta en .env - el engine no arrancara." -ForegroundColor Red
        exit 1
    }

    foreach ($svc in (Get-Services)) {
        $name = $svc.Name
        if (-not (Test-Path $svc.Exe)) {
            Write-Host "X Falta el ejecutable de $name : $($svc.Exe)" -ForegroundColor Red
            Write-Host "  Corre primero .\deploy.ps1 (construye venv/engine/frontend y descarga caddy)." -ForegroundColor Yellow
            exit 1
        }

        Remove-OneService $name
        Write-Host "-> Instalando $name ..." -ForegroundColor Cyan

        & $Nssm install $name $svc.Exe | Out-Null
        & $Nssm set $name AppParameters $svc.Args | Out-Null
        & $Nssm set $name AppDirectory  $svc.Dir  | Out-Null
        & $Nssm set $name Start SERVICE_AUTO_START | Out-Null
        # Auto-restart si el proceso muere
        & $Nssm set $name AppExit Default Restart | Out-Null
        & $Nssm set $name AppRestartDelay 3000 | Out-Null
        # Logs con rotación (10 MB)
        & $Nssm set $name AppStdout (Join-Path $LogDir "$name.log") | Out-Null
        & $Nssm set $name AppStderr (Join-Path $LogDir "$name.log") | Out-Null
        & $Nssm set $name AppRotateFiles 1 | Out-Null
        & $Nssm set $name AppRotateBytes 10485760 | Out-Null

        if ($svc.Env.Count -gt 0) {
            & $Nssm set $name AppEnvironmentExtra $svc.Env | Out-Null
        }

        # El backend depende de Postgres (si se configuró el nombre del servicio)
        if ($name -eq "bootwa-backend" -and $PostgresServiceName) {
            & $Nssm set $name DependOnService $PostgresServiceName | Out-Null
        }
    }
    Write-Host "OK Servicios registrados." -ForegroundColor Green
}

function Invoke-Each($verb) {
    foreach ($svc in (Get-Services)) {
        $name = $svc.Name
        if (Test-ServiceExists $name) {
            & $Nssm $verb $name 2>$null | Out-Null
            Write-Host "  $verb -> $name" -ForegroundColor DarkGray
        } else {
            Write-Host "  ! $name no existe (instala con: .\native\services.ps1 install)" -ForegroundColor Yellow
        }
    }
}

function Show-Status {
    foreach ($svc in (Get-Services)) {
        $name = $svc.Name
        $s = Get-Service -Name $name -ErrorAction SilentlyContinue
        if ($s) {
            $color = if ($s.Status -eq "Running") { "Green" } else { "Yellow" }
            Write-Host ("  {0,-16} {1}" -f $name, $s.Status) -ForegroundColor $color
        } else {
            Write-Host ("  {0,-16} NO INSTALADO" -f $name) -ForegroundColor Red
        }
    }
    Write-Host ""
    Write-Host "  Logs: $LogDir\bootwa-*.log   |   Front: http://localhost:8080"
}

switch ($Action) {
    "install"   { Install-Services; Invoke-Each "start"; Write-Host ""; Show-Status }
    "uninstall" { foreach ($svc in (Get-Services)) { Remove-OneService $svc.Name }; Write-Host "OK Servicios eliminados." -ForegroundColor Green }
    "start"     { Invoke-Each "start";   Show-Status }
    "stop"      { Invoke-Each "stop";    Show-Status }
    "restart"   { Invoke-Each "restart"; Show-Status }
    "status"    { Show-Status }
}
