# =============================================================================
# webhook-publico-admin.ps1 — EJECUTAR COMO ADMINISTRADOR
#
# Deja funcional el webhook de Meta en https://www.loggingcar.com/webhook:
#   1. Reinicia el servicio BootWhatsapp (carga el META_VERIFY_TOKEN nuevo del .env)
#   2. Verifica que IIS tenga URL Rewrite y ARR instalados
#   3. Habilita el proxy de ARR y agrega la regla /webhook -> 127.0.0.1:8080
#      (la regla vive en applicationHost.config, NO toca los archivos de
#       C:\Publicacion_Captura ni afecta ninguna otra ruta del sitio)
#   4. Prueba el handshake igual que lo hace Meta
#
# Uso:  powershell -ExecutionPolicy Bypass -File .\native\webhook-publico-admin.ps1
# =============================================================================
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

$RuleName    = 'BootWhatsapp webhook'
$BackendUrl  = 'http://127.0.0.1:8080/webhook'

# El token se LEE del .env (que no se versiona). Antes estaba escrito aqui en
# duro, y este repo es publico: cualquiera podia leer el verify token de Meta.
# Debe ser el MISMO valor que usa el backend, o el handshake de Meta falla.
$Repo = Split-Path $PSScriptRoot -Parent
$m = Select-String -Path (Join-Path $Repo ".env") -Pattern '^\s*META_VERIFY_TOKEN\s*=(.*)$' | Select-Object -First 1
if (-not $m) {
    Write-Host "ERROR: META_VERIFY_TOKEN no esta en $Repo\.env" -ForegroundColor Red
    exit 1
}
$VerifyToken = ($m.Matches[0].Groups[1].Value -replace '\s+#.*$', '').Trim()
if (-not $VerifyToken) {
    Write-Host "ERROR: META_VERIFY_TOKEN esta vacio en $Repo\.env" -ForegroundColor Red
    exit 1
}

Write-Host "== 1/4 Reiniciando servicio BootWhatsapp ==" -ForegroundColor Cyan
Restart-Service -Name BootWhatsapp -Force
Start-Sleep -Seconds 5
$local = curl.exe -s -o NUL -w "%{http_code}" --max-time 15 "http://localhost:8080/webhook?hub.mode=subscribe&hub.verify_token=$VerifyToken&hub.challenge=ok"
if ($local -ne '200') {
    # waitress puede tardar en levantar; reintenta una vez
    Start-Sleep -Seconds 10
    $local = curl.exe -s -o NUL -w "%{http_code}" --max-time 15 "http://localhost:8080/webhook?hub.mode=subscribe&hub.verify_token=$VerifyToken&hub.challenge=ok"
}
if ($local -eq '200') {
    Write-Host "   OK: el backend acepta el token nuevo." -ForegroundColor Green
} else {
    Write-Host "   ERROR: el backend respondio HTTP $local con el token nuevo." -ForegroundColor Red
    Write-Host "   Revisa logs\backend.err antes de continuar." -ForegroundColor Red
    exit 1
}

Write-Host "== 2/4 Verificando modulos de IIS ==" -ForegroundColor Cyan
$falta = @()
if (-not (Test-Path "$env:SystemRoot\System32\inetsrv\rewrite.dll"))       { $falta += 'URL Rewrite 2.1  ->  https://www.iis.net/downloads/microsoft/url-rewrite' }
if (-not (Test-Path "$env:SystemRoot\System32\inetsrv\requestRouter.dll")) { $falta += 'Application Request Routing 3.0  ->  https://www.iis.net/downloads/microsoft/application-request-routing' }
if ($falta) {
    Write-Host "   Faltan modulos de IIS (instalalos y vuelve a ejecutar este script):" -ForegroundColor Red
    $falta | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
    exit 1
}
Write-Host "   OK: URL Rewrite y ARR presentes." -ForegroundColor Green

Write-Host "== 3/4 Configurando regla de proxy en IIS ==" -ForegroundColor Cyan
Import-Module WebAdministration
$apphost = 'MACHINE/WEBROOT/APPHOST'

# Habilita el modo proxy de ARR a nivel servidor (idempotente)
Set-WebConfigurationProperty -PSPath $apphost -Filter 'system.webServer/proxy' -Name 'enabled' -Value 'True'

# Sitio que atiende el 443 (www.loggingcar.com)
$site = Get-Website | Where-Object {
    $_.State -eq 'Started' -and ($_.bindings.Collection | Where-Object { $_.bindingInformation -like '*:443:*' })
} | Select-Object -First 1
if (-not $site) { Write-Host "   ERROR: no encontre un sitio IIS con binding en 443." -ForegroundColor Red; exit 1 }
Write-Host "   Sitio detectado: $($site.Name)"

# Regla solo para la ruta exacta /webhook, guardada en applicationHost.config
$ruleFilter = "system.webServer/rewrite/rules/rule[@name='$RuleName']"
if (Get-WebConfiguration -PSPath $apphost -Location $site.Name -Filter $ruleFilter -ErrorAction SilentlyContinue) {
    Clear-WebConfiguration -PSPath $apphost -Location $site.Name -Filter $ruleFilter
}
Add-WebConfigurationProperty -PSPath $apphost -Location $site.Name -Filter 'system.webServer/rewrite/rules' -Name '.' `
    -Value @{ name = $RuleName; patternSyntax = 'ECMAScript'; stopProcessing = 'True' }
Set-WebConfigurationProperty -PSPath $apphost -Location $site.Name -Filter "$ruleFilter/match"  -Name 'url'  -Value '^webhook$'
Set-WebConfigurationProperty -PSPath $apphost -Location $site.Name -Filter "$ruleFilter/action" -Name 'type' -Value 'Rewrite'
Set-WebConfigurationProperty -PSPath $apphost -Location $site.Name -Filter "$ruleFilter/action" -Name 'url'  -Value $BackendUrl
Write-Host "   OK: regla '$RuleName' -> $BackendUrl" -ForegroundColor Green

Write-Host "== 4/4 Probando el handshake por el 443 (como lo hara Meta) ==" -ForegroundColor Cyan
$resp = curl.exe -k -s --max-time 15 --resolve www.loggingcar.com:443:127.0.0.1 `
    "https://www.loggingcar.com/webhook?hub.mode=subscribe&hub.verify_token=$VerifyToken&hub.challenge=12345"
if ($resp -eq '12345') {
    Write-Host "   EXITO: el webhook responde el challenge por HTTPS." -ForegroundColor Green
    Write-Host ""
    Write-Host "Ya puedes configurar en Meta Developers:" -ForegroundColor Cyan
    Write-Host "   Callback URL : https://www.loggingcar.com/webhook"
    Write-Host "   Verify Token : $VerifyToken"
} else {
    Write-Host "   ERROR: respuesta inesperada del 443: '$resp'" -ForegroundColor Red
    Write-Host "   La regla quedo creada; revisa que ARR este activo (paso 3) o comparte esta salida." -ForegroundColor Yellow
    exit 1
}
