# ─────────────────────────────────────────────────────────────────────────────
# arreglar_fotos_dominio.ps1 — Hace que las FOTOS se vean al entrar por el
# dominio (IIS). EJECUTAR COMO ADMINISTRADOR.
#
# Causa: el web.config del sitio solo reenvía /api al backend; las imágenes
# ahora se sirven por /media con URL firmada (seguridad) y IIS no las reenvía.
# Este script agrega la regla de /media (igual a la de /api que ya existe).
#   1. Respalda el web.config actual en C:\BootWhatsapp\backups\
#   2. Escribe el web.config con la regla nueva
# No toca base de datos, backend, engine ni nada más. IIS recarga el
# web.config solo, sin reiniciar el sitio.
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Stop"
$Dst    = "C:\inetpub\bootwatsapp\web.config"
$Backup = "C:\BootWhatsapp\backups\web.config_pre_media_20260728"
$LogDir = "C:\BootWhatsapp\logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path "$LogDir\arreglar_fotos_dominio.log" -Force | Out-Null

function Fin($codigo) {
    try { Stop-Transcript | Out-Null } catch {}
    Read-Host "Presiona ENTER para cerrar"
    exit $codigo
}

$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) { Write-Host "Debe ejecutarse como Administrador." -ForegroundColor Red; Fin 1 }

Write-Host "[1/2] Respaldando web.config actual..." -ForegroundColor Cyan
Copy-Item $Dst $Backup -Force
Write-Host "      Respaldo: $Backup" -ForegroundColor Green

Write-Host "[2/2] Escribiendo web.config con la regla de /media..." -ForegroundColor Cyan
@'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <rule name="API to Waitress" stopProcessing="true">
                    <match url="^api/(.*)" />
                    <action type="Rewrite" url="http://127.0.0.1:8000/api/{R:1}" />
                </rule>
                <rule name="Media to Waitress" stopProcessing="true">
                    <match url="^media/(.*)" />
                    <action type="Rewrite" url="http://127.0.0.1:8000/media/{R:1}" />
                </rule>
                <rule name="React Router" stopProcessing="true">
                    <match url=".*" />
                    <conditions logicalGrouping="MatchAll">
                        <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
                    </conditions>
                    <action type="Rewrite" url="/" />
                </rule>
            </rules>
        </rewrite>
        <proxy enabled="true" />
    </system.webServer>
</configuration>
'@ | Out-File -FilePath $Dst -Encoding UTF8
Write-Host "      web.config actualizado (IIS lo recarga solo)." -ForegroundColor Green

Write-Host ""
Write-Host "Listo. Refresca el chat (Ctrl+Shift+R): las fotos deben verse." -ForegroundColor Green
Fin 0
