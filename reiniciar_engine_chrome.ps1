# ─────────────────────────────────────────────────────────────────────────────
# reiniciar_engine_chrome.ps1 — Reinicia el engine de WhatsApp usando el
# Google Chrome YA INSTALADO en el servidor (v150).
# EJECUTAR COMO ADMINISTRADOR.
#
# Motivo: whatsapp-web.js 1.34.7 pide un Chrome que puppeteer intenta
# descargar, pero el antivirus pone en cuarentena el chrome.exe descargado.
# Solución: apuntar puppeteer al Chrome instalado (PUPPETEER_EXECUTABLE_PATH).
# NO toca base de datos, backend, IIS ni la sesión de WhatsApp guardada.
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Continue"
$Repo   = "C:\BootWhatsapp"
$Engine = Join-Path $Repo "Frontend\bootwhatsapp_frontend\engine"
$LogDir = Join-Path $Repo "logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\reiniciar_engine_chrome.log" -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red; Fin 1 }

$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chrome)) { Write-Host "No se encontro Chrome en $chrome" -ForegroundColor Red; Fin 1 }

Write-Host "[1/2] Deteniendo el engine..." -ForegroundColor Cyan
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -match 'app\.js' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 3

Write-Host "[2/2] Arrancando el engine con el Chrome instalado (v150)..." -ForegroundColor Cyan
function Get-EnvValue($key) {
    $m = Select-String -Path (Join-Path $Repo ".env") -Pattern "^\s*$([regex]::Escape($key))\s*=(.*)$" | Select-Object -First 1
    if (-not $m) { return $null }
    return (($m.Matches[0].Groups[1].Value -replace '\s+#.*$', '').Trim())
}
$env:ENGINE_SECRET = Get-EnvValue "WHATSAPP_ENGINE_SECRET"
$env:PORT = "3001"
$env:DJANGO_URL = "http://127.0.0.1:8000"
$env:PUPPETEER_EXECUTABLE_PATH = $chrome
Start-Process -FilePath "node" -ArgumentList "app.js" `
    -WorkingDirectory $Engine -WindowStyle Hidden `
    -RedirectStandardOutput "$LogDir\engine.out" -RedirectStandardError "$LogDir\engine.err"
Start-Sleep -Seconds 6

$up = Test-NetConnection localhost -Port 3001 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($up) {
    Write-Host ""
    Write-Host "Engine arriba en el puerto 3001." -ForegroundColor Green
    Write-Host "Ahora ve a Numeros Puente y crea la conexion QR de nuevo." -ForegroundColor Green
} else {
    Write-Host "El engine no responde en el 3001. Revisa logs\engine.err" -ForegroundColor Red
}
Fin 0
