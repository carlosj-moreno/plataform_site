# =============================================================================
# aplicar_seguridad_bind.ps1  —  EJECUTAR COMO ADMINISTRADOR (UAC)
# -----------------------------------------------------------------------------
# Endurece el servicio BootWhatsapp:
#   1) Cambia el bind de waitress de 0.0.0.0:8000 (todas las interfaces, HTTP
#      plano) a 127.0.0.1:8000 (solo loopback). El proxy native/serve.py ya
#      habla con 127.0.0.1:8000, así que el sitio sigue funcionando; lo que se
#      cierra es el acceso DIRECTO al backend desde la red saltándose el proxy.
#   2) Reinicia el servicio, con lo que además toma efecto DEBUG=False (ya
#      aplicado en Backend\bootwhatsapp\.env).
#
# Reversible: para volver atrás, pon AppParameters = "--port=8000 core.wsgi:application".
# =============================================================================

$ErrorActionPreference = 'Stop'

# --- Requiere elevación ------------------------------------------------------
$admin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Host "Este script debe ejecutarse como Administrador. Reabriendo con UAC..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList `
        "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    return
}

$nssm = 'C:\nssm\nssm-2.24\win64\nssm.exe'
if (-not (Test-Path $nssm)) { throw "No se encontró nssm en $nssm" }

Write-Host "Config actual del servicio BootWhatsapp:" -ForegroundColor Cyan
& $nssm get BootWhatsapp AppParameters

# --- 1) Bind a loopback ------------------------------------------------------
& $nssm set BootWhatsapp AppParameters "--listen=127.0.0.1:8000 core.wsgi:application"
Write-Host "Nuevo AppParameters:" -ForegroundColor Green
& $nssm get BootWhatsapp AppParameters

# --- 2) Reinicio (aplica bind loopback + DEBUG=False) ------------------------
Write-Host "Reiniciando servicio BootWhatsapp..." -ForegroundColor Cyan
Restart-Service BootWhatsapp
Start-Sleep -Seconds 4

# --- 3) Verificación ---------------------------------------------------------
Write-Host "`nPuertos en escucha para 8000:" -ForegroundColor Cyan
Get-NetTCPConnection -State Listen -LocalPort 8000 -ErrorAction SilentlyContinue |
    Select-Object LocalAddress, LocalPort |
    Format-Table -AutoSize

$onLoopback = Get-NetTCPConnection -State Listen -LocalPort 8000 -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalAddress -eq '127.0.0.1' }
$onAll = Get-NetTCPConnection -State Listen -LocalPort 8000 -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalAddress -eq '0.0.0.0' }

if ($onLoopback -and -not $onAll) {
    Write-Host "OK: el backend ahora escucha SOLO en 127.0.0.1:8000." -ForegroundColor Green
} else {
    Write-Host "ATENCION: revisa el bind; aún aparece 0.0.0.0. Verifica que waitress-serve acepte --listen." -ForegroundColor Red
}

Write-Host "`nListo. Verifica que el sitio carga a través del proxy (puerto 8080/dominio)." -ForegroundColor Green
