# -----------------------------------------------------------------------------
# instalar_vigilante_puente.ps1 - Registra la tarea programada que vigila el
# puente de WhatsApp cada 5 minutos.
#
# NO hace falta Administrador: la tarea se registra bajo el usuario actual,
# igual que "BootWhatsapp exportar fotos".
#
# Es la red de seguridad mientras no este instalado el servicio bootwa-engine
# (instalar_servicio_puente.bat, ese si pide Administrador). Si el servicio
# existe, el vigilante se aparta y no arranca nada por su cuenta.
# -----------------------------------------------------------------------------
$ErrorActionPreference = "Stop"

$Nombre = "BootWhatsapp vigilar puente"
$Script = "C:\BootWhatsapp\vigilar_puente.ps1"

if (-not (Test-Path $Script)) {
    Write-Host "X No se encontro $Script" -ForegroundColor Red
    Read-Host "Presiona ENTER para cerrar"
    exit 1
}

$usuario = "$env:USERNAME"

$accion = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Script`""

# Cada 5 minutos, indefinidamente, mas una pasada al iniciar sesion (que es
# cuando vuelve el servidor tras un reinicio).
$t1 = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(2) `
        -RepetitionInterval (New-TimeSpan -Minutes 5)
$t2 = New-ScheduledTaskTrigger -AtLogOn -User $usuario

$principal = New-ScheduledTaskPrincipal -UserId $usuario -LogonType Interactive -RunLevel Limited

# MultipleInstances IgnoreNew: si una pasada se alarga levantando el puente, la
# siguiente NO arranca un segundo node peleando por el mismo perfil de Chrome.
$ajustes = New-ScheduledTaskSettingsSet -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10) -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $Nombre -Action $accion -Trigger $t1, $t2 `
    -Principal $principal -Settings $ajustes -Force `
    -Description "Comprueba cada 5 min que el puente de WhatsApp (127.0.0.1:3001) sigue vivo y lo levanta si se cayo. No hace nada si existe el servicio bootwa-engine." | Out-Null

$t = Get-ScheduledTask -TaskName $Nombre -ErrorAction SilentlyContinue
Write-Host ""
if ($t) {
    Write-Host "LISTO. Tarea '$Nombre' registrada ($($t.State))." -ForegroundColor Green
    Write-Host "  Revisa el registro en: C:\BootWhatsapp\logs\vigilar_puente.log"
    Write-Host "  (ese log solo se escribe cuando encuentra el puente caido)"
} else {
    Write-Host "X No se pudo registrar la tarea." -ForegroundColor Red
}
Write-Host ""
Read-Host "Presiona ENTER para cerrar"
