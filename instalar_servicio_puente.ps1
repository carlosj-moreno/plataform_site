# -----------------------------------------------------------------------------
# instalar_servicio_puente.ps1 - Convierte el puente de WhatsApp (node app.js)
# en un SERVICIO DE WINDOWS con arranque automatico y reinicio si se cae.
#
# EJECUTAR COMO ADMINISTRADOR (clic derecho > Ejecutar con PowerShell, o desde
# una consola elevada). Registrar servicios exige elevacion.
#
# POR QUE: el 2026-08-13 el servidor se reinicio a las 17:55. El backend volvio
# solo (es servicio), pero el puente se arrancaba A MANO, asi que quedo muerto
# 15 horas: sin puente no hay QR ni mensajes. Con esto, un reinicio o una caida
# del proceso lo levantan solos.
#
# NO toca la base de datos, ni el backend, ni el sitio web, ni la sesion de
# WhatsApp ya vinculada (vive en .wwebjs_auth y sobrevive al reinicio).
# -----------------------------------------------------------------------------
$ErrorActionPreference = "Continue"

$Repo    = "C:\BootWhatsapp"
$Engine  = Join-Path $Repo "Frontend\bootwhatsapp_frontend\engine"
$LogDir  = Join-Path $Repo "logs"
$Servicio = "bootwa-engine"
$Puerto  = 3001

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path (Join-Path $LogDir "instalar_servicio_puente.log") -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Write-Host ""
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

function Test-Puerto($p) {
    # Contra 127.0.0.1 a proposito: el engine escucha SOLO en IPv4, y probar
    # contra "localhost" resuelve primero a ::1 y da un falso "esta caido".
    try {
        $c = New-Object Net.Sockets.TcpClient
        $c.Connect("127.0.0.1", $p)
        $c.Close()
        return $true
    } catch { return $false }
}

# -- 1. Comprobaciones previas ------------------------------------------------
Write-Host "[1/6] Comprobando el entorno..." -ForegroundColor Cyan

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) {
    Write-Host "  X Debe ejecutarse como Administrador." -ForegroundColor Red
    Fin 1
}

if (-not (Test-Path (Join-Path $Engine "app.js"))) {
    Write-Host "  X No se encontro el engine en $Engine" -ForegroundColor Red
    Fin 1
}

# nssm: primero el que ya usa este servidor, luego bin\ del repo, luego el PATH.
$Nssm = $null
foreach ($ruta in @("C:\nssm\nssm-2.24\win64\nssm.exe", (Join-Path $Repo "bin\nssm.exe"))) {
    if (Test-Path $ruta) { $Nssm = $ruta; break }
}
if (-not $Nssm) {
    $cmd = Get-Command nssm.exe -ErrorAction SilentlyContinue
    if ($cmd) { $Nssm = $cmd.Source }
}
if (-not $Nssm) {
    Write-Host "  X No se encontro nssm.exe." -ForegroundColor Red
    Fin 1
}

$cmdNode = Get-Command node.exe -ErrorAction SilentlyContinue
if (-not $cmdNode) {
    Write-Host "  X No se encontro node.exe en el PATH." -ForegroundColor Red
    Fin 1
}
$Node = $cmdNode.Source

$Chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $Chrome)) {
    Write-Host "  X No se encontro Chrome en $Chrome" -ForegroundColor Red
    Write-Host "    El engine lo necesita: el antivirus pone en cuarentena el Chrome que descarga puppeteer." -ForegroundColor Yellow
    Fin 1
}

# El secret debe ser el MISMO que WHATSAPP_ENGINE_SECRET del backend, o Django
# rechaza todo lo que mande el engine (y el QR nunca llega a la web).
$m = Select-String -Path (Join-Path $Repo ".env") -Pattern '^\s*WHATSAPP_ENGINE_SECRET\s*=(.*)$' | Select-Object -First 1
if (-not $m) {
    Write-Host "  X WHATSAPP_ENGINE_SECRET no esta en $Repo\.env" -ForegroundColor Red
    Fin 1
}
$Secret = ($m.Matches[0].Groups[1].Value -replace '\s+#.*$', '').Trim()

Write-Host "  OK  nssm   : $Nssm"
Write-Host "  OK  node   : $Node"
Write-Host "  OK  chrome : $Chrome"
Write-Host "  OK  secret : encontrado en .env"

# -- 2. Parar el puente arrancado a mano --------------------------------------
Write-Host "[2/6] Deteniendo el puente que corre suelto (si lo hay)..." -ForegroundColor Cyan
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -match '(^|\s)"?app\.js"?\s*$' } |
    ForEach-Object {
        Write-Host "  - matando node pid=$($_.ProcessId)" -ForegroundColor DarkGray
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }
Start-Sleep -Seconds 3

# Chrome huerfano agarrando el perfil de sesion: si queda vivo, el arranque
# falla con "The browser is already running for ...".
Get-CimInstance Win32_Process |
    Where-Object { $_.Name -match 'chrome' -and $_.CommandLine -match 'session-conn_' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

# -- 3. Limpiar restos de sesiones corruptas ----------------------------------
Write-Host "[3/6] Limpiando restos de perfiles corruptos..." -ForegroundColor Cyan
Get-ChildItem (Join-Path $Engine ".wwebjs_auth") -Directory -Filter "_viejo_conn_*" -ErrorAction SilentlyContinue |
    ForEach-Object {
        Write-Host "  - borrando $($_.Name)" -ForegroundColor DarkGray
        Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }

# -- 4. Registrar el servicio -------------------------------------------------
Write-Host "[4/6] Registrando el servicio $Servicio ..." -ForegroundColor Cyan

if (Get-Service -Name $Servicio -ErrorAction SilentlyContinue) {
    Write-Host "  - ya existia: se borra y se vuelve a crear" -ForegroundColor DarkGray
    & $Nssm stop $Servicio 2>$null | Out-Null
    & $Nssm remove $Servicio confirm | Out-Null
    Start-Sleep -Seconds 2
}

& $Nssm install $Servicio $Node | Out-Null
& $Nssm set $Servicio AppParameters "app.js" | Out-Null
& $Nssm set $Servicio AppDirectory  $Engine  | Out-Null
& $Nssm set $Servicio DisplayName   "BootWhatsapp - Puente WhatsApp (QR)" | Out-Null
& $Nssm set $Servicio Description   "Motor node/whatsapp-web.js que mantiene las lineas QR. Escucha en 127.0.0.1:3001." | Out-Null

# Arranque automatico con el servidor: es justo lo que faltaba.
& $Nssm set $Servicio Start SERVICE_AUTO_START | Out-Null

# Si el proceso muere por lo que sea, NSSM lo vuelve a levantar a los 5s.
& $Nssm set $Servicio AppExit Default Restart | Out-Null
& $Nssm set $Servicio AppRestartDelay 5000 | Out-Null
# Sin esto, un fallo instantaneo y repetido hace que NSSM se rinda y marque el
# servicio como "pausado". 10s = margen para considerar que arranco bien.
& $Nssm set $Servicio AppThrottle 10000 | Out-Null

# Entorno. PUPPETEER_EXECUTABLE_PATH va aqui a proposito: estaba como variable
# de USUARIO, y un servicio (que corre como LocalSystem) NO la hereda.
& $Nssm set $Servicio AppEnvironmentExtra `
    "ENGINE_SECRET=$Secret" `
    "PORT=$Puerto" `
    "DJANGO_URL=http://127.0.0.1:8000" `
    "PUPPETEER_EXECUTABLE_PATH=$Chrome" | Out-Null

# Logs con rotacion a 10 MB (antes crecian sin limite).
& $Nssm set $Servicio AppStdout (Join-Path $LogDir "bootwa-engine.log") | Out-Null
& $Nssm set $Servicio AppStderr (Join-Path $LogDir "bootwa-engine.log") | Out-Null
& $Nssm set $Servicio AppRotateFiles 1 | Out-Null
& $Nssm set $Servicio AppRotateBytes 10485760 | Out-Null

# Que arranque DESPUES del backend: al levantar, el engine le pregunta a Django
# que lineas restaurar. Si Django no responde reintenta 5 veces, pero mejor no
# gastar esos reintentos en cada arranque del servidor.
if (Get-Service -Name "BootWhatsapp" -ErrorAction SilentlyContinue) {
    & $Nssm set $Servicio DependOnService "BootWhatsapp" | Out-Null
    Write-Host "  - depende del servicio BootWhatsapp (backend)" -ForegroundColor DarkGray
}

Write-Host "  OK Servicio registrado." -ForegroundColor Green

# -- 5. Arrancar --------------------------------------------------------------
Write-Host "[5/6] Arrancando..." -ForegroundColor Cyan
& $Nssm start $Servicio | Out-Null

$arriba = $false
foreach ($i in 1..20) {
    Start-Sleep -Seconds 2
    if (Test-Puerto $Puerto) { $arriba = $true; break }
}

# -- 6. Resultado -------------------------------------------------------------
Write-Host "[6/6] Comprobando..." -ForegroundColor Cyan
$s = Get-Service -Name $Servicio -ErrorAction SilentlyContinue
Write-Host ""
Write-Host ("  Servicio : {0}" -f $(if ($s) { $s.Status } else { "NO EXISTE" }))
Write-Host ("  Puerto {0} : {1}" -f $Puerto, $(if ($arriba) { "ESCUCHANDO" } else { "SIN RESPUESTA" }))
Write-Host ""

if ($arriba -and $s -and $s.Status -eq "Running") {
    Write-Host "LISTO. El puente ya es un servicio: arranca solo con el servidor y" -ForegroundColor Green
    Write-Host "se reinicia solo si se cae." -ForegroundColor Green
    Write-Host ""
    Write-Host "Para manejarlo:" -ForegroundColor Cyan
    Write-Host "  Get-Service bootwa-engine          (ver estado)"
    Write-Host "  Restart-Service bootwa-engine      (reiniciar, como Administrador)"
    Write-Host "  logs\bootwa-engine.log             (registro del puente)"
    Write-Host ""
    Write-Host "IMPORTANTE: ya no arranques el puente con local.ps1 ni con" -ForegroundColor Yellow
    Write-Host "reiniciar_engine_chrome.ps1 — habria DOS puentes peleando por el" -ForegroundColor Yellow
    Write-Host "mismo perfil de Chrome y la linea se caeria en bucle." -ForegroundColor Yellow
    Fin 0
} else {
    Write-Host "El servicio no llego a escuchar en el $Puerto." -ForegroundColor Red
    Write-Host "Mira el detalle en: $LogDir\bootwa-engine.log" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Causa mas probable: el servicio corre como LocalSystem y Chrome no" -ForegroundColor Yellow
    Write-Host "arranca en esa cuenta. Solucion: abre services.msc, busca" -ForegroundColor Yellow
    Write-Host "'BootWhatsapp - Puente WhatsApp (QR)', pestana 'Iniciar sesion'," -ForegroundColor Yellow
    Write-Host "elige 'Esta cuenta' y pon el usuario del servidor con su clave." -ForegroundColor Yellow
    Fin 1
}
