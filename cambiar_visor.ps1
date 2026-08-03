# ─────────────────────────────────────────────────────────────────────────────
# cambiar_visor.ps1 — Reemplaza el visor viejo (vite preview) por el nuevo
# proxy serve.py en el puerto 8080. EJECUTAR COMO ADMINISTRADOR.
# Motivo: el frontend nuevo llama a la API por el MISMO origen (/api) y
# vite preview no hace proxy — por eso el login se quedaba cargando.
# NO toca la base de datos, el backend ni el engine.
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Continue"
$Repo   = "C:\BootWhatsapp"
$Front  = Join-Path $Repo "Frontend\bootwhatsapp_frontend"
$LogDir = Join-Path $Repo "logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\cambiar_visor.log" -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red; Fin 1 }

Write-Host "[1/2] Deteniendo el visor viejo (vite preview)..." -ForegroundColor Cyan
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -match 'vite\.js.+preview' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

Write-Host "[2/2] Arrancando el visor nuevo (serve.py con proxy /api) en el 8080..." -ForegroundColor Cyan
$py = Join-Path $Repo "Backend\bootwhatsapp\.venv\Scripts\python.exe"
Start-Process -FilePath $py `
    -ArgumentList "$Repo\native\serve.py", "--port", "8080", "--host", "0.0.0.0", "--backend", "127.0.0.1:8000", "--dist", "$Front\dist", "--forwarded-proto", "http" `
    -WorkingDirectory $Repo -WindowStyle Hidden `
    -RedirectStandardOutput "$LogDir\frontend.out" -RedirectStandardError "$LogDir\frontend.err"
Start-Sleep -Seconds 4

$up = Test-NetConnection localhost -Port 8080 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($up) {
    Write-Host ""
    Write-Host "Visor nuevo funcionando en http://localhost:8080" -ForegroundColor Green
    Write-Host "Abre la pagina con Ctrl+F5 para refrescar y vuelve a iniciar sesion." -ForegroundColor Green
} else {
    Write-Host "El puerto 8080 no responde. Revisa logs\frontend.err" -ForegroundColor Red
}
Fin 0
