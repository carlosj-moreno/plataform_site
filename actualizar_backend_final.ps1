# ─────────────────────────────────────────────────────────────────────────────
# actualizar_backend_final.ps1 — Actualización final del backend (2026-07-28).
# EJECUTAR COMO ADMINISTRADOR.
#
# SEGURIDAD DE LA BASE DE DATOS (BD "Sandar", compartida con el sistema del
# negocio — 71 tablas mae_*/sec_* que Django NO conoce ni toca):
#   - Las 9 migraciones (0107-0115) fueron auditadas una por una: SOLO crean
#     tablas/columnas nuevas en las tablas chat_* de Django + 3 rellenos
#     benignos. CERO operaciones de borrado. CERO contacto con mae_*/sec_*.
#   - Respaldo previo de los datos Django ya tomado:
#     C:\BootWhatsapp\backups\respaldo_django_pre_migracion_20260728.json
#
# Pasos:
#   1. Detiene el backend (necesario: Windows bloquea los .pyd de opencv en uso)
#   2. Cambia opencv-headless -> opencv-contrib-headless + instala rapidocr
#      (secuencia exacta que indica requirements.txt)
#   3. Aplica las migraciones auditadas (manage.py migrate)
#   4. Arranca el backend de nuevo
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Continue"
$Repo    = "C:\BootWhatsapp"
$Backend = Join-Path $Repo "Backend\bootwhatsapp"
$Py      = Join-Path $Backend ".venv\Scripts\python.exe"
$LogDir  = Join-Path $Repo "logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\actualizar_backend_final.log" -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red; Fin 1 }

Write-Host "[1/4] Deteniendo el backend..." -ForegroundColor Cyan
Stop-Service -Name "BootWhatsapp" -Force
Start-Sleep -Seconds 3

Write-Host "[2/4] Actualizando dependencias Python (opencv contrib + rapidocr)..." -ForegroundColor Cyan
cmd /c """$Py"" -m pip uninstall -y opencv-python opencv-python-headless opencv-contrib-python > ""$LogDir\pip-opencv.out"" 2>&1"
cmd /c """$Py"" -m pip install -r ""$Backend\requirements.txt"" >> ""$LogDir\pip-opencv.out"" 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "pip install FALLO. Revisa logs\pip-opencv.out. Reiniciando el backend con lo que hay..." -ForegroundColor Red
    Start-Service -Name "BootWhatsapp"; Fin 1
}
# rapidocr arrastra opencv-python "full": quitarlo y reafirmar la contrib-headless
cmd /c """$Py"" -m pip uninstall -y opencv-python >> ""$LogDir\pip-opencv.out"" 2>&1"
cmd /c """$Py"" -m pip install --force-reinstall --no-deps ""opencv-contrib-python-headless>=4.9,<5"" >> ""$LogDir\pip-opencv.out"" 2>&1"
# Verificación: cv2 debe importar y traer el detector de WeChat
cmd /c """$Py"" -c ""import cv2; print('cv2', cv2.__version__, '| wechat:', hasattr(cv2, 'wechat_qrcode_WeChatQRCode'))"" >> ""$LogDir\pip-opencv.out"" 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "cv2 quedo roto tras el cambio. Revisa logs\pip-opencv.out. NO se migra; reiniciando backend..." -ForegroundColor Red
    Start-Service -Name "BootWhatsapp"; Fin 1
}
Write-Host "      Dependencias OK." -ForegroundColor Green

Write-Host "[3/4] Aplicando migraciones auditadas (solo tablas chat_* de Django)..." -ForegroundColor Cyan
cmd /c "cd /d ""$Backend"" && ""$Py"" manage.py migrate > ""$LogDir\migrate.out"" 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "migrate FALLO. Revisa logs\migrate.out. El backend NO se arranca hasta revisar." -ForegroundColor Red
    Fin 1
}
Get-Content "$LogDir\migrate.out" | Select-Object -Last 12
Write-Host "      Migraciones aplicadas." -ForegroundColor Green

Write-Host "[4/4] Arrancando el backend..." -ForegroundColor Cyan
Start-Service -Name "BootWhatsapp"
Start-Sleep -Seconds 8

Write-Host ""
Write-Host "=== Estado final ===" -ForegroundColor Cyan
foreach ($p in @(@{n="Frontend"; port=8080}, @{n="Backend"; port=8000}, @{n="Engine"; port=3001})) {
    $up = Test-NetConnection localhost -Port $p.port -InformationLevel Quiet -WarningAction SilentlyContinue
    Write-Host ("  {0,-9} :{1}  {2}" -f $p.n, $p.port, $(if ($up) { "UP" } else { "DOWN" })) -ForegroundColor $(if ($up) { "Green" } else { "Red" })
}
Write-Host ""
Write-Host "Listo. Dile a Claude 'listo' para la verificacion final de datos y funciones." -ForegroundColor Green
Fin 0
