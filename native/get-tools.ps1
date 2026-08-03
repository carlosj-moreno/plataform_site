# ─────────────────────────────────────────────────────────────────────────────
# get-tools.ps1 — Descarga las herramientas del despliegue nativo a bin\ (idempotente).
#
#   bin\caddy.exe  — reverse-proxy + servidor estático del SPA
#   bin\nssm.exe   — registra los procesos como servicios de Windows
#
# Si el servidor NO tiene internet, copia manualmente esos dos .exe a bin\ y este
# script no descargará nada.
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Repo   = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$BinDir = Join-Path $Repo "bin"
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

# ── Caddy ────────────────────────────────────────────────────────────────────
$Caddy = Join-Path $BinDir "caddy.exe"
if (Test-Path $Caddy) {
    Write-Host "OK caddy.exe ya está en bin\" -ForegroundColor DarkGray
} else {
    Write-Host "-> Descargando caddy.exe ..." -ForegroundColor Cyan
    # La API de Caddy entrega el ejecutable Windows directamente (sin zip).
    Invoke-WebRequest -Uri "https://caddyserver.com/api/download?os=windows&arch=amd64" `
        -OutFile $Caddy -UseBasicParsing
    Write-Host "OK caddy.exe descargado." -ForegroundColor Green
}

# ── NSSM ─────────────────────────────────────────────────────────────────────
$Nssm = Join-Path $BinDir "nssm.exe"
if (Test-Path $Nssm) {
    Write-Host "OK nssm.exe ya está en bin\" -ForegroundColor DarkGray
} else {
    Write-Host "-> Descargando nssm.exe ..." -ForegroundColor Cyan
    $tmpZip = Join-Path $env:TEMP "nssm-2.24.zip"
    $tmpDir = Join-Path $env:TEMP "nssm-2.24-extract"
    Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile $tmpZip -UseBasicParsing
    if (Test-Path $tmpDir) { Remove-Item -Recurse -Force $tmpDir }
    Expand-Archive -Path $tmpZip -DestinationPath $tmpDir -Force
    # Estructura: nssm-2.24\win64\nssm.exe (usamos win64 — Windows 11 es 64-bit)
    $src = Join-Path $tmpDir "nssm-2.24\win64\nssm.exe"
    if (-not (Test-Path $src)) { throw "No se encontró win64\nssm.exe dentro del zip de NSSM." }
    Copy-Item $src $Nssm -Force
    Remove-Item -Recurse -Force $tmpDir
    Remove-Item -Force $tmpZip
    Write-Host "OK nssm.exe descargado." -ForegroundColor Green
}
