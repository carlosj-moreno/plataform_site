# -----------------------------------------------------------------------------
# vigilar_puente.ps1 - Comprueba cada pocos minutos que el puente de WhatsApp
# sigue vivo y, si no lo esta, lo levanta.
#
# POR QUE: el puente escucha en el 3001 y es lo unico que conecta el sistema con
# WhatsApp. El 14/08/2026 Windows apago el servidor por una actualizacion, el
# puente corria a mano y murio con el: estuvo 92 HORAS mudo y nadie se entero,
# porque el backend y la web siguieron funcionando con normalidad. Que la
# plataforma se vea bien NO dice nada del puente.
#
# Esto es la RED DE SEGURIDAD, no el arreglo de fondo. El arreglo de fondo es
# instalar_servicio_puente.bat (registra el servicio bootwa-engine, que arranca
# con el servidor). Este vigilante existe porque el servicio pide permiso de
# Administrador y puede tardar en instalarse.
#
# CONVIVENCIA: si el servicio bootwa-engine ya existe, este script NO arranca
# nada por su cuenta. Dos puentes peleando por el mismo perfil de Chrome tumban
# la linea en bucle.
# -----------------------------------------------------------------------------
$ErrorActionPreference = "Continue"

$Repo    = "C:\BootWhatsapp"
$Engine  = Join-Path $Repo "Frontend\bootwhatsapp_frontend\engine"
$LogDir  = Join-Path $Repo "logs"
$Log     = Join-Path $LogDir "vigilar_puente.log"
$Servicio = "bootwa-engine"
$Puerto  = 3001

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Escribir($texto) {
    $linea = "{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $texto
    Add-Content -Path $Log -Value $linea -Encoding utf8
}

# El log se trunca a 2 MB para que no crezca sin limite como hizo engine.out
# (llego a 4,6 GB en agosto).
if ((Test-Path $Log) -and ((Get-Item $Log).Length -gt 2MB)) {
    $cola = Get-Content $Log -Tail 500
    Set-Content -Path $Log -Value $cola -Encoding utf8
}

# Contra 127.0.0.1 a proposito: el engine escucha SOLO en IPv4, y probar contra
# "localhost" resuelve primero a ::1 y da un falso "esta caido".
function Test-Puerto {
    try {
        $c = New-Object Net.Sockets.TcpClient
        $iar = $c.BeginConnect("127.0.0.1", $Puerto, $null, $null)
        $ok = $iar.AsyncWaitHandle.WaitOne(3000, $false)
        if ($ok) { $c.EndConnect($iar) }
        $c.Close()
        return $ok
    } catch { return $false }
}

# -- 1. Si el puente ya es un servicio, el servicio manda -----------------------
$svc = Get-Service -Name $Servicio -ErrorAction SilentlyContinue
if ($svc) {
    if ($svc.Status -ne "Running") {
        Escribir "El servicio $Servicio esta $($svc.Status); intentando arrancarlo."
        try { Start-Service $Servicio -ErrorAction Stop; Escribir "Servicio arrancado." }
        catch { Escribir "NO se pudo arrancar el servicio (hace falta Administrador): $($_.Exception.Message)" }
    }
    exit 0
}

# -- 2. Sin servicio: se vigila el proceso suelto -------------------------------
if (Test-Puerto) { exit 0 }   # todo bien, ni se escribe en el log

Escribir "El puerto $Puerto no responde: el puente esta caido. Levantandolo."

# Restos del intento anterior: node de app.js y Chrome agarrando el perfil. Si
# quedan vivos, el arranque falla con "The browser is already running for ...".
Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match '(^|\s)"?app\.js"?\s*$' } |
    ForEach-Object {
        Escribir "  matando node huerfano pid=$($_.ProcessId)"
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'chrome' -and $_.CommandLine -match 'session-conn_' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 3

# El secret debe ser el MISMO que WHATSAPP_ENGINE_SECRET del backend, o Django
# rechaza todo lo que mande el engine (y el QR nunca llega a la web).
$m = Select-String -Path (Join-Path $Repo ".env") -Pattern '^\s*WHATSAPP_ENGINE_SECRET\s*=(.*)$' | Select-Object -First 1
if (-not $m) { Escribir "  X WHATSAPP_ENGINE_SECRET no esta en $Repo\.env; no se puede arrancar."; exit 1 }
$env:ENGINE_SECRET = ($m.Matches[0].Groups[1].Value -replace '\s+#.*$', '').Trim()
$env:PORT = "$Puerto"
$env:DJANGO_URL = "http://127.0.0.1:8000"
# Va explicito porque el Chrome que descarga puppeteer lo pone en cuarentena el
# antivirus de este servidor.
$env:PUPPETEER_EXECUTABLE_PATH = "C:\Program Files\Google\Chrome\Application\chrome.exe"

$node = (Get-Command node.exe -ErrorAction SilentlyContinue).Source
if (-not $node) { Escribir "  X no se encontro node.exe en el PATH."; exit 1 }

# Un fichero por arranque: si se reescribiera siempre engine.err, el reintento
# siguiente borraria justo el error que explica por que se cayo. Se podan los de
# mas de 14 dias para que no se acumulen.
$sello = Get-Date -Format "yyyyMMdd-HHmmss"
Get-ChildItem $LogDir -Filter "engine-*.??r" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-14) } |
    Remove-Item -Force -ErrorAction SilentlyContinue
Get-ChildItem $LogDir -Filter "engine-*.out" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-14) } |
    Remove-Item -Force -ErrorAction SilentlyContinue

$p = Start-Process -FilePath $node -ArgumentList "app.js" -WorkingDirectory $Engine `
        -RedirectStandardOutput (Join-Path $LogDir "engine-$sello.out") `
        -RedirectStandardError  (Join-Path $LogDir "engine-$sello.err") `
        -WindowStyle Hidden -PassThru
Escribir "  node arrancado pid=$($p.Id); esperando a que abra el $Puerto..."

$arriba = $false
foreach ($i in 1..20) {
    Start-Sleep -Seconds 2
    if (Test-Puerto) { $arriba = $true; break }
}

if ($arriba) {
    Escribir "  OK el puente responde en el $Puerto."
} else {
    Escribir "  X el puente NO llego a escuchar. Mirar logs\engine-$sello.err."
}
