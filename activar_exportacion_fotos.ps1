# ─────────────────────────────────────────────────────────────────────────────
# activar_exportacion_fotos.ps1 — Re-registra la tarea "BootWhatsapp exportar
# fotos" para que corra como SYSTEM: las fotos se exportan a
# C:\FotosVehiculos\temporal cada 30 min AUNQUE NADIE tenga sesión abierta.
# EJECUTAR COMO ADMINISTRADOR (una sola vez).
# ─────────────────────────────────────────────────────────────────────────────
$LogDir = "C:\BootWhatsapp\logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\activar_exportacion_fotos.log" -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red; Fin 1 }

Write-Host "Registrando la tarea como SYSTEM (corre sin sesion abierta)..." -ForegroundColor Cyan
schtasks /Create /F /TN "BootWhatsapp exportar fotos" /SC MINUTE /MO 30 /RU SYSTEM `
    /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\BootWhatsapp\exportar_fotos_temporal.ps1"
if ($LASTEXITCODE -ne 0) { Write-Host "schtasks fallo." -ForegroundColor Red; Fin 1 }

Write-Host "Probando la tarea..." -ForegroundColor Cyan
schtasks /Run /TN "BootWhatsapp exportar fotos" | Out-Null
Start-Sleep -Seconds 25
$log = "C:\BootWhatsapp\logs\exportar_fotos.log"
if (Test-Path $log) {
    Write-Host "Ultima corrida:" -ForegroundColor Green
    Get-Content $log
} else {
    Write-Host "La tarea corrio pero aun no hay log - revisa en unos minutos." -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Listo. La exportacion corre cada 30 min aunque no haya nadie conectado." -ForegroundColor Green
Fin 0
