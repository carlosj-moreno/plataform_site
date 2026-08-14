# ─────────────────────────────────────────────────────────────────────────────
# arreglar_dominio_plataforma.ps1 — Devuelve www.loggingcar.com a la plataforma.
# EJECUTAR COMO ADMINISTRADOR (UAC).
#
# Qué pasó (diagnóstico 2026-08-05): el 2026-08-03 ~23:15 el sitio de IIS que
# atiende www.loggingcar.com quedó apuntando a C:\Publicacion_Captura (sistema
# viejo de capturas ASP.NET). Ese web.config no reenvía /api ni /media al
# backend, así que la plataforma "se cayó" para todo el que entra por dominio.
#
# Este script:
#   1. Muestra el sitio de IIS que tiene el binding de www.loggingcar.com y
#      PIDE CONFIRMACIÓN antes de tocar nada.
#   2. Respalda la ruta física actual (solo se anota; no borra archivos).
#   3. Vuelve a apuntar la raíz del sitio a C:\inetpub\bootwatsapp.
#   4. Verifica que /api responde a través del dominio.
#
# NO borra C:\Publicacion_Captura ni toca su contenido. Si el sistema de
# capturas debe seguir publicado, hay que darle su PROPIO binding (otro
# subdominio o puerto) en IIS — eso es una decisión aparte.
# Reversible: para volver atrás, apunta el sitio de nuevo a la ruta que este
# script deja anotada en el log.
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Stop"
$LogDir = "C:\BootWhatsapp\logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\arreglar_dominio_plataforma.log" -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red; Fin 1 }

Import-Module WebAdministration

# ── 1. Encontrar el sitio con el binding del dominio ─────────────────────────
$dominio = "www.loggingcar.com"
$sitio = Get-Website | Where-Object {
    $_.bindings.Collection | Where-Object { $_.bindingInformation -like "*${dominio}*" }
} | Select-Object -First 1
if (-not $sitio) {
    Write-Host "No se encontró ningún sitio de IIS con binding para $dominio." -ForegroundColor Red
    Get-Website | Format-Table name, physicalPath -AutoSize
    Fin 1
}

$rutaActual  = $sitio.physicalPath
$rutaCorrecta = "C:\inetpub\bootwatsapp"
Write-Host "Sitio:        $($sitio.name)" -ForegroundColor Cyan
Write-Host "Ruta actual:  $rutaActual"    -ForegroundColor Yellow
Write-Host "Ruta nueva:   $rutaCorrecta"  -ForegroundColor Green

if ($rutaActual -eq $rutaCorrecta) {
    Write-Host "El sitio YA apunta a la plataforma. Nada que hacer." -ForegroundColor Green
    Fin 0
}
if (-not (Test-Path "$rutaCorrecta\web.config")) {
    Write-Host "OJO: no existe $rutaCorrecta\web.config — no se cambia nada." -ForegroundColor Red
    Fin 1
}

$resp = Read-Host "¿Apuntar '$($sitio.name)' de '$rutaActual' a '$rutaCorrecta'? (escribe SI)"
if ($resp -ne "SI") { Write-Host "Cancelado; no se tocó nada."; Fin 0 }

# ── 2/3. Cambiar la ruta física (la anterior queda anotada en el transcript) ─
Set-ItemProperty "IIS:\Sites\$($sitio.name)" -Name physicalPath -Value $rutaCorrecta
Write-Host "Ruta cambiada. (Para revertir: volver a $rutaActual)" -ForegroundColor Green

# ── 4. Verificación de la cadena completa dominio -> IIS -> backend ──────────
Start-Sleep -Seconds 2
$code = & curl.exe -sk --resolve "${dominio}:443:127.0.0.1" -o NUL -w "%{http_code}" `
    -X POST -H "Content-Type: application/json" `
    -d '{"username":"__ping__","password":"__ping__"}' `
    "https://$dominio/api/auth/token/"
if ($code -eq "401" -or $code -eq "400") {
    Write-Host "OK: /api responde por el dominio (HTTP $code = el backend contesta)." -ForegroundColor Green
    Write-Host "Pide a los usuarios refrescar con Ctrl+Shift+R e iniciar sesión." -ForegroundColor Green
} else {
    Write-Host "ATENCION: /api devolvió HTTP $code. Revisa el web.config de $rutaCorrecta." -ForegroundColor Red
}
Fin 0
