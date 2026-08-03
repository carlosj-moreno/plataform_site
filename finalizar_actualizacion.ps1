# ─────────────────────────────────────────────────────────────────────────────
# finalizar_actualizacion.ps1 — Pasos finales de la actualización (2026-07-28).
# EJECUTAR COMO ADMINISTRADOR. Hace SOLO lo que queda:
#   1. Actualiza dependencias del engine (npm install) y lo reinicia
#   2. Reinicia el servicio del backend (BootWhatsapp / waitress)
#   3. Reinicia el visor del frontend (vite preview) para servir el build nuevo
# Ya hechos antes: git pull, pip install, migrate, collectstatic, permisos de
# dist\ y build del frontend. NO toca la base de datos ni borra datos.
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Continue"   # las advertencias de npm/node NO deben abortar
$Repo    = "C:\BootWhatsapp"
$Front   = Join-Path $Repo "Frontend\bootwhatsapp_frontend"
$LogDir  = Join-Path $Repo "logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\finalizar_actualizacion.log" -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red; Fin 1 }

# 1. Engine: detener, actualizar whatsapp-web.js (npm install respeta node_modules) y relanzar
Write-Host "[1/3] Actualizando y reiniciando el engine de WhatsApp..." -ForegroundColor Cyan
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -match 'app\.js' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

# cmd /c evita que PowerShell 5.1 convierta el stderr de npm en errores fatales
cmd /c "cd /d ""$Front\engine"" && npm install > ""$LogDir\engine-npminstall.out"" 2>&1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "npm install del engine FALLO. Revisa logs\engine-npminstall.out" -ForegroundColor Red
    Fin 1
}
Write-Host "      Dependencias del engine actualizadas." -ForegroundColor Green

function Get-EnvValue($key) {
    $m = Select-String -Path (Join-Path $Repo ".env") -Pattern "^\s*$([regex]::Escape($key))\s*=(.*)$" | Select-Object -First 1
    if (-not $m) { return $null }
    return (($m.Matches[0].Groups[1].Value -replace '\s+#.*$', '').Trim())
}
$env:ENGINE_SECRET = Get-EnvValue "WHATSAPP_ENGINE_SECRET"
$env:PORT = "3001"
$env:DJANGO_URL = "http://127.0.0.1:8000"
Start-Process -FilePath "node" -ArgumentList "app.js" `
    -WorkingDirectory (Join-Path $Front "engine") -WindowStyle Hidden `
    -RedirectStandardOutput "$LogDir\engine.out" -RedirectStandardError "$LogDir\engine.err"
Write-Host "      Engine reiniciado." -ForegroundColor Green

# 2. Backend (servicio waitress)
Write-Host "[2/3] Reiniciando el servicio del backend..." -ForegroundColor Cyan
Restart-Service -Name "BootWhatsapp" -Force
Write-Host "      Backend reiniciado." -ForegroundColor Green

# 3. Visor del frontend (vite preview): cachea dist\ en memoria al arrancar,
#    hay que reiniciarlo para que sirva el build nuevo.
Write-Host "[3/3] Reiniciando el visor del frontend..." -ForegroundColor Cyan
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -match 'vite\.js.+preview' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2
Start-Process -FilePath "node" -ArgumentList "node_modules\vite\bin\vite.js", "preview", "--port", "8080", "--host", "127.0.0.1" `
    -WorkingDirectory $Front -WindowStyle Hidden `
    -RedirectStandardOutput "$LogDir\frontend-preview.out" -RedirectStandardError "$LogDir\frontend-preview.err"
Write-Host "      Visor reiniciado." -ForegroundColor Green

Start-Sleep -Seconds 6
Write-Host ""
Write-Host "=== Estado final ===" -ForegroundColor Cyan
foreach ($p in @(@{n="Frontend"; port=8080}, @{n="Backend"; port=8000}, @{n="Engine"; port=3001})) {
    $up = Test-NetConnection localhost -Port $p.port -InformationLevel Quiet -WarningAction SilentlyContinue
    Write-Host ("  {0,-9} :{1}  {2}" -f $p.n, $p.port, $(if ($up) { "UP" } else { "DOWN" })) -ForegroundColor $(if ($up) { "Green" } else { "Red" })
}
Write-Host ""
Write-Host "Listo. Abre http://localhost:8080 (Ctrl+F5 para refrescar) y entra al Inventario Vehicular." -ForegroundColor Green
Fin 0
