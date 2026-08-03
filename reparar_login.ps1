# ─────────────────────────────────────────────────────────────────────────────
# reparar_login.ps1 — Aplica el arreglo del login (2026-07-28).
# EJECUTAR COMO ADMINISTRADOR. Hace 2 cosas:
#   1. Reinicia el servicio del backend para cargar el parche del login
#      (el código de GitHub referenciaba un modelo "Cartera" que no fue subido;
#      ya se parcheó en el servidor de forma tolerante).
#   2. Cambia el visor del puerto 8080: vite preview (sin proxy /api, causa del
#      "cargando" infinito) -> serve.py (con proxy, como pide el código nuevo).
# NO toca la base de datos ni borra nada.
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Continue"
$Repo   = "C:\BootWhatsapp"
$Front  = Join-Path $Repo "Frontend\bootwhatsapp_frontend"
$LogDir = Join-Path $Repo "logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\reparar_login.log" -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red; Fin 1 }

Write-Host "[1/2] Reiniciando el backend (carga el parche del login)..." -ForegroundColor Cyan
Restart-Service -Name "BootWhatsapp" -Force
Start-Sleep -Seconds 6
Write-Host "      Backend reiniciado." -ForegroundColor Green

Write-Host "[2/2] Cambiando el visor del puerto 8080..." -ForegroundColor Cyan
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -match 'vite\.js.+preview' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2
$py = Join-Path $Repo "Backend\bootwhatsapp\.venv\Scripts\python.exe"
Start-Process -FilePath $py `
    -ArgumentList "$Repo\native\serve.py", "--port", "8080", "--host", "0.0.0.0", "--backend", "127.0.0.1:8000", "--dist", "$Front\dist", "--forwarded-proto", "http" `
    -WorkingDirectory $Repo -WindowStyle Hidden `
    -RedirectStandardOutput "$LogDir\frontend.out" -RedirectStandardError "$LogDir\frontend.err"
Start-Sleep -Seconds 4
Write-Host "      Visor nuevo en el 8080." -ForegroundColor Green

Write-Host ""
Write-Host "=== Estado final ===" -ForegroundColor Cyan
foreach ($p in @(@{n="Frontend"; port=8080}, @{n="Backend"; port=8000}, @{n="Engine"; port=3001})) {
    $up = Test-NetConnection localhost -Port $p.port -InformationLevel Quiet -WarningAction SilentlyContinue
    Write-Host ("  {0,-9} :{1}  {2}" -f $p.n, $p.port, $(if ($up) { "UP" } else { "DOWN" })) -ForegroundColor $(if ($up) { "Green" } else { "Red" })
}
# Prueba real del endpoint que rompía el login
try {
    $body = '{"username":"__ping__","password":"__ping__"}'
    $null = Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/token/" -Method Post -ContentType "application/json" -Body $body -UseBasicParsing -TimeoutSec 10
} catch {
    $st = $_.Exception.Response.StatusCode.value__
    if ($st -eq 401 -or $st -eq 400) { Write-Host "  API respondiendo correctamente." -ForegroundColor Green }
    else { Write-Host "  API respondio HTTP $st (revisar)." -ForegroundColor Yellow }
}
Write-Host ""
Write-Host "Listo. Abre http://localhost:8080, refresca con Ctrl+F5 e inicia sesion." -ForegroundColor Green
Fin 0
