# ─────────────────────────────────────────────────────────────────────────────
# reiniciar_backend.ps1 — Reinicia SOLO el servicio del backend para cargar
# el ajuste de nombres de archivos del inventario (sin marca de tiempo).
# EJECUTAR COMO ADMINISTRADOR. No toca base de datos, engine, IIS ni nada más.
# ─────────────────────────────────────────────────────────────────────────────
$LogDir = "C:\BootWhatsapp\logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\reiniciar_backend.log" -Force | Out-Null

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) {
    Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"; exit 1
}

Write-Host "Reiniciando el backend..." -ForegroundColor Cyan
Restart-Service -Name "BootWhatsapp" -Force
Start-Sleep -Seconds 8
$up = Test-NetConnection localhost -Port 8000 -InformationLevel Quiet -WarningAction SilentlyContinue
Write-Host $(if ($up) { "Backend arriba (puerto 8000). Listo." } else { "El backend no responde en el 8000 - avisa a Claude." }) -ForegroundColor $(if ($up) { "Green" } else { "Red" })
try { Stop-Transcript | Out-Null } catch {}
Read-Host "Presiona ENTER para cerrar"
