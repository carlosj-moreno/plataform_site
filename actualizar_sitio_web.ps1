# ─────────────────────────────────────────────────────────────────────────────
# actualizar_sitio_web.ps1 — Actualiza el frontend del SITIO PÚBLICO (IIS).
# EJECUTAR COMO ADMINISTRADOR.
#
# Contexto: el dominio (www.loggingcar.com) lo sirve IIS desde
# C:\inetpub\bootwatsapp — esa copia es del 5 de julio y por eso NO se ven
# el Inventario Vehicular ni las funciones nuevas al entrar por el dominio.
#
# Este script:
#   1. Respalda la copia actual en C:\BootWhatsapp\backups\ (no borra nada)
#   2. Copia el build nuevo (dist) encima
#   3. NO toca web.config (ahí vive el reenvío /api -> backend, ya correcto)
#   4. NO toca la base de datos, ni el backend, ni Sandar, ni IIS
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Stop"
$Src    = "C:\BootWhatsapp\Frontend\bootwhatsapp_frontend\dist"
$Dst    = "C:\inetpub\bootwatsapp"
$Backup = "C:\BootWhatsapp\backups\bootwatsapp_iis_pre_20260728"
$LogDir = "C:\BootWhatsapp\logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\actualizar_sitio_web.log" -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red; Fin 1 }
if (-not (Test-Path "$Src\index.html")) { Write-Host "No existe el build en $Src" -ForegroundColor Red; Fin 1 }

Write-Host "[1/2] Respaldando la copia actual del sitio..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $Backup | Out-Null
Copy-Item "$Dst\*" $Backup -Recurse -Force
Write-Host "      Respaldo en $Backup" -ForegroundColor Green

Write-Host "[2/2] Copiando el build nuevo (sin tocar web.config)..." -ForegroundColor Cyan
# Primero los assets (nombres con hash nuevos, no chocan), al final index.html.
Copy-Item "$Src\assets\*" "$Dst\assets\" -Force
Get-ChildItem $Src -File | Where-Object { $_.Name -ne 'index.html' } | ForEach-Object { Copy-Item $_.FullName $Dst -Force }
Copy-Item "$Src\index.html" $Dst -Force
Write-Host "      Sitio actualizado." -ForegroundColor Green

Write-Host ""
Write-Host "Listo. Entra por el dominio de siempre y refresca con Ctrl+Shift+R." -ForegroundColor Green
Write-Host "Deben aparecer: Inventario Vehicular, Mi Equipo, Carteras." -ForegroundColor Green
Fin 0
