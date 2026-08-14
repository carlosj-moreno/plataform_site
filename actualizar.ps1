# -----------------------------------------------------------------------------
# actualizar.ps1 - COMANDO UNICO para poner al dia todo el sistema.
#
# Uso normal (doble clic en actualizar.bat, o desde PowerShell):
#     .\actualizar.ps1
#
# Hace, en este orden:
#   1. git pull en los TRES repos (raiz, backend, frontend)
#   2. pip install / npm ci  -> SOLO si cambiaron requirements.txt o package.json
#   3. migrate               -> muestra el plan y aplica lo pendiente
#   4. npm run build         -> compila el frontend
#   5. (pide UAC) respalda el sitio, reinicia el backend y publica la web
#
# EL ORDEN IMPORTA: primero reinicia el backend y despues publica la web. Al
# reves, la web nueva le pediria rutas de API que el backend viejo no tiene
# todavia y saldrian 404 hasta el reinicio.
#
# NO BORRA NADA:
#   - respalda el sitio en una carpeta NUEVA con fecha antes de tocarlo
#   - copia los assets ENCIMA; los viejos se quedan, asi no se rompe la pagina
#     de quien la tenga abierta en ese momento
#   - no toca web.config, ni la BD, ni el puente de WhatsApp, ni .wwebjs_auth
#   - si algo falla, se detiene y deja la version anterior funcionando
#
# La plataforma se ve en:  https://api.loggingcar.com:8092
# (OJO: www.loggingcar.com es el sistema VIEJO de capturas, es otra cosa.)
# -----------------------------------------------------------------------------
param(
    [switch]$SoloPublicar   # uso interno: la fase que necesita Administrador
)

$ErrorActionPreference = "Stop"

$Repo     = "C:\BootWhatsapp"
$Backend  = Join-Path $Repo "Backend\bootwhatsapp"
$Front    = Join-Path $Repo "Frontend\bootwhatsapp_frontend"
$Dist     = Join-Path $Front "dist"
$Sitio    = "C:\inetpub\bootwatsapp"
$Servicio = "BootWhatsapp"
$LogDir   = Join-Path $Repo "logs"
$Py       = Join-Path $Backend ".venv\Scripts\python.exe"
$UrlApp   = "https://api.loggingcar.com:8092"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Fin($codigo) {
    Write-Host ""
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}
function Paso($t) { Write-Host ""; Write-Host "== $t" -ForegroundColor Cyan }
function Bien($t) { Write-Host "   OK  $t" -ForegroundColor Green }
function Mal($t)  { Write-Host "   X   $t" -ForegroundColor Red }
function Nota($t) { Write-Host "       $t" -ForegroundColor DarkGray }

function Es-Admin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Puerto-Arriba($p) {
    try { $c = New-Object Net.Sockets.TcpClient; $c.Connect("127.0.0.1", $p); $c.Close(); return $true }
    catch { return $false }
}

# =============================================================================
# FASE 2 - Requiere Administrador: respaldar, reiniciar y publicar
# =============================================================================
if ($SoloPublicar) {
    Start-Transcript -Path (Join-Path $LogDir "actualizar-publicar.log") -Force | Out-Null
    Write-Host "=== Publicando (fase con permisos de Administrador) ===" -ForegroundColor Cyan

    if (-not (Es-Admin)) { Mal "Esta fase necesita Administrador."; Stop-Transcript | Out-Null; Fin 1 }
    if (-not (Test-Path (Join-Path $Dist "index.html")))  { Mal "No hay build en $Dist";   Stop-Transcript | Out-Null; Fin 1 }
    if (-not (Test-Path (Join-Path $Sitio "index.html"))) { Mal "No existe el sitio $Sitio"; Stop-Transcript | Out-Null; Fin 1 }

    Paso "Respaldando el sitio actual (no se borra nada)"
    $Backup = Join-Path $Repo ("backups\bootwatsapp_iis_pre_" + (Get-Date -Format "yyyyMMdd_HHmm"))
    New-Item -ItemType Directory -Force -Path $Backup | Out-Null
    Copy-Item (Join-Path $Sitio "*") $Backup -Recurse -Force
    Bien "$((Get-ChildItem $Backup -Recurse -File | Measure-Object).Count) archivos en $Backup"
    Nota "para revertir la web: copiar esa carpeta de vuelta a $Sitio"

    Paso "Reiniciando el backend (primero el backend, despues la web)"
    Restart-Service -Name $Servicio -Force
    Start-Sleep -Seconds 5
    $arriba = $false
    foreach ($i in 1..20) {
        if (Puerto-Arriba 8000) { $arriba = $true; break }
        Start-Sleep -Seconds 2
    }
    if (-not $arriba) {
        Mal "El backend no volvio a escuchar en el 8000."
        Nota "NO se publica la web nueva: la anterior sigue funcionando."
        Nota "Revisa $LogDir\backend.err"
        Stop-Transcript | Out-Null
        Fin 1
    }
    Bien "backend arriba con el codigo nuevo"

    Paso "Publicando la web (assets primero, index.html al final)"
    New-Item -ItemType Directory -Force -Path (Join-Path $Sitio "assets") | Out-Null
    Copy-Item (Join-Path $Dist "assets\*") (Join-Path $Sitio "assets\") -Force
    Get-ChildItem $Dist -File | Where-Object { $_.Name -ne 'index.html' } | ForEach-Object {
        Copy-Item $_.FullName $Sitio -Force
    }
    Copy-Item (Join-Path $Dist "index.html") $Sitio -Force
    Bien "web publicada (web.config intacto)"

    Paso "Verificacion"
    foreach ($p in @(@{n="Backend"; port=8000}, @{n="Puente WhatsApp"; port=3001}, @{n="IIS"; port=8092})) {
        $up = Puerto-Arriba $p.port
        $color = "Red"; $txt = "DOWN"
        if ($up) { $color = "Green"; $txt = "UP" }
        Write-Host ("   {0,-16} :{1}  {2}" -f $p.n, $p.port, $txt) -ForegroundColor $color
    }
    Write-Host ""
    Write-Host "LISTO. Abre $UrlApp y refresca con Ctrl+Shift+R." -ForegroundColor Green
    Write-Host "El puente de WhatsApp no se toco: la linea sigue vinculada." -ForegroundColor Cyan
    Stop-Transcript | Out-Null
    Fin 0
}

# =============================================================================
# FASE 1 - Usuario normal: traer codigo, migrar y compilar
# =============================================================================
Start-Transcript -Path (Join-Path $LogDir "actualizar.log") -Force | Out-Null
Write-Host "=== Actualizando BootWhatsapp ===" -ForegroundColor Cyan
Write-Host "(esta parte NO necesita Administrador; el UAC se pide al final)" -ForegroundColor DarkGray

# -- git ----------------------------------------------------------------------
$Git = $null
$c = Get-Command git.exe -ErrorAction SilentlyContinue
if ($c) { $Git = $c.Source }
if (-not $Git) {
    foreach ($p in @("C:\Users\usrcustomer\Tools\MinGit\cmd\git.exe", "$env:ProgramFiles\Git\cmd\git.exe")) {
        if (Test-Path $p) { $Git = $p; break }
    }
}
if (-not $Git) { Mal "No se encontro git.exe"; Stop-Transcript | Out-Null; Fin 1 }

$repos = @(
    @{ Ruta = $Repo;    Rama = "main";    Nombre = "raiz (plataform_site)" },
    @{ Ruta = $Backend; Rama = "develop"; Nombre = "backend" },
    @{ Ruta = $Front;   Rama = "develop"; Nombre = "frontend" }
)

Paso "1/5  Trayendo cambios de GitHub"
$huboCambios = $false
foreach ($r in $repos) {
    $sucio = & $Git -C $r.Ruta status --porcelain
    $antes = (& $Git -C $r.Ruta rev-parse HEAD).Trim()
    if ($sucio) {
        Nota "$($r.Nombre): hay $(($sucio | Measure-Object).Count) archivo(s) sin commitear (no estorban al pull)"
    }
    & $Git -C $r.Ruta fetch origin --quiet
    & $Git -C $r.Ruta pull --ff-only origin $r.Rama --quiet
    if ($LASTEXITCODE -ne 0) {
        Mal "$($r.Nombre): el pull no pudo avanzar en linea recta."
        Nota "Suele ser porque hay commits locales sin subir. Revisalo a mano; no se toca nada mas."
        Stop-Transcript | Out-Null
        Fin 1
    }
    $despues = (& $Git -C $r.Ruta rev-parse HEAD).Trim()
    if ($antes -ne $despues) {
        $huboCambios = $true
        $n = (& $Git -C $r.Ruta rev-list --count "$antes..$despues").Trim()
        Bien "$($r.Nombre): $n commit(s) nuevos"
    } else {
        Bien "$($r.Nombre): ya estaba al dia"
    }
    # Guardamos el rango para saber si cambiaron los manifiestos
    $r.Antes = $antes
    $r.Despues = $despues
}

# -- dependencias (solo si cambiaron los manifiestos) -------------------------
Paso "2/5  Dependencias"
$rb = $repos | Where-Object { $_.Nombre -eq "backend" }
$rf = $repos | Where-Object { $_.Nombre -eq "frontend" }

$reqCambio = $false
if ($rb.Antes -ne $rb.Despues) {
    $ch = & $Git -C $Backend diff --name-only "$($rb.Antes)..$($rb.Despues)" -- requirements.txt
    if ($ch) { $reqCambio = $true }
}
if ($reqCambio) {
    Write-Host "   requirements.txt cambio: instalando..." -ForegroundColor Yellow
    & $Py -m pip install -r (Join-Path $Backend "requirements.txt")
    if ($LASTEXITCODE -ne 0) { Mal "pip install fallo"; Stop-Transcript | Out-Null; Fin 1 }
    Bien "dependencias de Python al dia"
} else {
    Bien "Python: sin cambios"
}

$pkgCambio = $false
if ($rf.Antes -ne $rf.Despues) {
    $ch = & $Git -C $Front diff --name-only "$($rf.Antes)..$($rf.Despues)" -- package.json package-lock.json
    if ($ch) { $pkgCambio = $true }
}
if ($pkgCambio) {
    Write-Host "   package.json cambio: instalando..." -ForegroundColor Yellow
    Push-Location $Front
    cmd /c "npm ci 2>&1" | Select-Object -Last 5
    $okNpm = ($LASTEXITCODE -eq 0)
    Pop-Location
    if (-not $okNpm) { Mal "npm ci fallo"; Stop-Transcript | Out-Null; Fin 1 }
    Bien "dependencias de Node al dia"
} else {
    Bien "Node: sin cambios"
}

# -- migraciones --------------------------------------------------------------
Paso "3/5  Migraciones de la base de datos"
Push-Location $Backend
$plan = & $Py manage.py migrate --plan 2>&1 | Out-String
if ($plan -match "No planned migration operations") {
    Bien "ninguna pendiente"
} else {
    Write-Host "   Se van a aplicar:" -ForegroundColor Yellow
    ($plan -split "`n") | Where-Object { $_ -match "^\s*chat\." } | ForEach-Object { Nota $_.Trim() }
    & $Py manage.py migrate
    if ($LASTEXITCODE -ne 0) {
        Mal "migrate fallo. NO se sigue; el sistema queda como estaba."
        Pop-Location; Stop-Transcript | Out-Null; Fin 1
    }
    Bien "migraciones aplicadas"
}
Pop-Location

# -- build --------------------------------------------------------------------
Paso "4/5  Compilando el frontend"
Push-Location $Front
cmd /c "npm run build 2>&1" | Select-Object -Last 4
$okBuild = ($LASTEXITCODE -eq 0)
Pop-Location
if (-not $okBuild) {
    Mal "El build fallo. NO se publica nada; la web actual sigue intacta."
    Stop-Transcript | Out-Null
    Fin 1
}
if (-not (Test-Path (Join-Path $Dist "index.html"))) {
    Mal "El build no dejo index.html en $Dist"
    Stop-Transcript | Out-Null
    Fin 1
}
Bien "compilado"

Stop-Transcript | Out-Null

# -- fase con UAC -------------------------------------------------------------
Paso "5/5  Publicando (Windows va a pedir permiso de Administrador)"
if (Es-Admin) {
    & $PSCommandPath -SoloPublicar
} else {
    $p = Start-Process -FilePath "powershell.exe" `
        -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"", "-SoloPublicar" `
        -Verb RunAs -PassThru
    $p.WaitForExit()
    Write-Host ""
    Write-Host "Fase de publicacion terminada (su detalle quedo en $LogDir\actualizar-publicar.log)." -ForegroundColor Cyan
    Write-Host "Abre $UrlApp y refresca con Ctrl+Shift+R." -ForegroundColor Green
    Fin 0
}
