# ─────────────────────────────────────────────────────────────────────────────
# harden.ps1 — Endurecimiento del servidor tras el pentest de julio 2026
# (informe CDS-TI Principal-001). Ejecutar EN EL SERVIDOR como Administrador:
#
#   powershell -ExecutionPolicy Bypass -File C:\BootWhatsapp\native\harden.ps1
#
# Qué hace por defecto (acciones de bajo riesgo):
#   HT-01  Restringe los archivos con secretos (.env, deploy.config.ps1) a
#          Administradores + SYSTEM + la cuenta indicada en -ServiceAccount.
#   HT-04  Quita el permiso de escritura de BUILTIN\Usuarios en los directorios
#          de binarios de terceros (Microfocus, NSSM, Zabbix) → quedan en RX.
#   HT-02  Busca restos de DJANGO_SUPERUSER_PASSWORD en el repo y los reporta.
#
# Qué hace SOLO con switches explícitos (pueden afectar a usuarios legítimos):
#   -FixSiiwis [-SiiwisAllowed "DOMINIO\Grupo",...]   (HT-03)
#          Quita "Todos" del share SIIWIS (SMB y NTFS) y deja solo
#          Administradores + SYSTEM + las cuentas de -SiiwisAllowed.
#   -RemoveUsersShare
#          Elimina el share SMB "Users" que expone C:\Users completo.
#
# Al final imprime el checklist de acciones MANUALES que este script no puede
# hacer (rotación de credenciales, parches, Tamper Protection, PostgreSQL).
# ─────────────────────────────────────────────────────────────────────────────
#Requires -RunAsAdministrator
param(
    [string]$RepoRoot = "C:\BootWhatsapp",
    # Cuenta que ejecuta el stack (necesita LEER los .env). Por defecto, la que
    # corre este script (sin el prefijo de elevación).
    [string]$ServiceAccount = [Security.Principal.WindowsIdentity]::GetCurrent().Name,
    [switch]$FixSiiwis,
    [string[]]$SiiwisAllowed = @(),
    [switch]$RemoveUsersShare
)
$ErrorActionPreference = "Continue"

# SIDs fijos → funcionan igual en Windows en español o inglés.
$SID_ADMINS    = "*S-1-5-32-544"   # BUILTIN\Administradores
$SID_SYSTEM    = "*S-1-5-18"       # NT AUTHORITY\SYSTEM
$SID_USERS     = "*S-1-5-32-545"   # BUILTIN\Usuarios
$SID_AUTHUSERS = "*S-1-5-11"       # Usuarios autentificados
$EveryoneName  = (New-Object Security.Principal.SecurityIdentifier("S-1-1-0")).Translate([Security.Principal.NTAccount]).Value  # "Todos"/"Everyone"

function Step($msg)  { Write-Host "`n== $msg" -ForegroundColor Cyan }
function Ok($msg)    { Write-Host "   OK  $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "   !!  $msg" -ForegroundColor Yellow }
function Fail($msg)  { Write-Host "   X   $msg" -ForegroundColor Red }

# ── HT-01: archivos con secretos ─────────────────────────────────────────────
Step "HT-01 (CRITICA): restringir archivos con secretos"
$secretFiles = @(
    (Join-Path $RepoRoot ".env"),
    (Join-Path $RepoRoot "deploy.config.ps1"),
    (Join-Path $RepoRoot "Backend\bootwhatsapp\.env")
)
foreach ($f in $secretFiles) {
    if (-not (Test-Path $f)) { Warn "No existe: $f (omitido)"; continue }
    icacls $f /inheritance:r /grant:r "${SID_ADMINS}:(F)" "${SID_SYSTEM}:(F)" "${ServiceAccount}:(R,W)" | Out-Null
    if ($LASTEXITCODE -eq 0) { Ok "$f -> solo Administradores, SYSTEM y $ServiceAccount" }
    else { Fail "icacls fallo en $f" }
}

# ── HT-02: restos de la contraseña del superusuario en archivos ──────────────
Step "HT-02 (ALTA): buscar DJANGO_SUPERUSER_PASSWORD en el repo"
$hits = Get-ChildItem -Path $RepoRoot -Recurse -File -Include *.json, *.ps1, *.bat, *.md -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(node_modules|\.venv|venv|\.git|dist)\\' } |
    Select-String -Pattern "DJANGO_SUPERUSER_PASSWORD" -List
if ($hits) {
    foreach ($h in $hits) { Fail "Contiene DJANGO_SUPERUSER_PASSWORD: $($h.Path)" }
    Warn "Edita esos archivos y elimina la contraseña. Luego cambia la clave real: manage.py changepassword admin"
} else {
    Ok "Sin restos de DJANGO_SUPERUSER_PASSWORD en el repo."
}

# ── HT-04: escritura de Usuarios en binarios de terceros ─────────────────────
Step "HT-04 (MEDIA): quitar escritura de Usuarios en directorios de binarios"
$binDirs = @("C:\Microfocus\bin", "C:\nssm\nssm-2.24\win64", "C:\zabbixLLA")
foreach ($d in $binDirs) {
    if (-not (Test-Path $d)) { Warn "No existe: $d (omitido)"; continue }
    # 1) materializar la herencia para poder editar los ACE heredados,
    # 2) Usuarios queda SOLO con lectura+ejecución (se van WriteData/AppendData),
    # 3) fuera el Modify de "Usuarios autentificados",
    # 4) Administradores y SYSTEM con control total.
    icacls $d /inheritance:d | Out-Null
    icacls $d /grant:r "${SID_USERS}:(OI)(CI)(RX)" | Out-Null
    icacls $d /remove:g $SID_AUTHUSERS | Out-Null
    icacls $d /grant "${SID_ADMINS}:(OI)(CI)(F)" "${SID_SYSTEM}:(OI)(CI)(F)" | Out-Null
    if ($LASTEXITCODE -eq 0) { Ok "$d -> Usuarios solo lectura/ejecución" }
    else { Fail "icacls fallo en $d (revisar a mano)" }
}

# ── HT-03: share SIIWIS con Control Total para "Todos" ───────────────────────
Step "HT-03 (ALTA): recurso compartido SIIWIS"
$siiwis = Get-SmbShare -Name "SIIWIS" -ErrorAction SilentlyContinue
if (-not $siiwis) {
    Warn "No hay share 'SIIWIS' en esta máquina (nada que hacer aquí)."
} elseif (-not $FixSiiwis) {
    Warn "El share SIIWIS existe pero NO se tocó. Este cambio puede cortar el acceso"
    Warn "a quienes lo usan (contabilidad/Siigo), así que requiere confirmación:"
    Warn "  .\native\harden.ps1 -FixSiiwis -SiiwisAllowed 'DOMINIO\GrupoContabilidad'"
} else {
    # Share ACL: fuera "Todos", entran Administradores + cuentas autorizadas.
    try {
        Revoke-SmbShareAccess -Name "SIIWIS" -AccountName "$EveryoneName" -Force -ErrorAction Stop | Out-Null
        Ok "Share SIIWIS: revocado '$EveryoneName'"
    } catch { Fail "No pude revocar '$EveryoneName' del share: $_" }
    $adminsName = (New-Object Security.Principal.SecurityIdentifier("S-1-5-32-544")).Translate([Security.Principal.NTAccount]).Value
    foreach ($acct in (@($adminsName) + $SiiwisAllowed)) {
        try {
            Grant-SmbShareAccess -Name "SIIWIS" -AccountName $acct -AccessRight Full -Force -ErrorAction Stop | Out-Null
            Ok "Share SIIWIS: acceso Full para $acct"
        } catch { Fail "No pude dar acceso a ${acct}: $_" }
    }
    # NTFS: fuera "Todos" (F heredable), entran Admins/SYSTEM + autorizados.
    $path = $siiwis.Path
    icacls $path /remove:g "*S-1-1-0" /t /c | Out-Null
    icacls $path /grant "${SID_ADMINS}:(OI)(CI)(F)" "${SID_SYSTEM}:(OI)(CI)(F)" | Out-Null
    foreach ($acct in $SiiwisAllowed) { icacls $path /grant "${acct}:(OI)(CI)(M)" | Out-Null }
    Ok "NTFS ${path}: 'Todos' eliminado; acceso = Administradores, SYSTEM$(if ($SiiwisAllowed) { ', ' + ($SiiwisAllowed -join ', ') })"
}

# ── Share "Users" (expone C:\Users por SMB) ──────────────────────────────────
Step "Share SMB 'Users' (C:\Users)"
$usersShare = Get-SmbShare -Name "Users" -ErrorAction SilentlyContinue
if (-not $usersShare) {
    Ok "No hay share 'Users'."
} elseif ($RemoveUsersShare) {
    try { Remove-SmbShare -Name "Users" -Force -ErrorAction Stop; Ok "Share 'Users' eliminado." }
    catch { Fail "No pude eliminar el share 'Users': $_" }
} else {
    Warn "Existe un share 'Users' que expone C:\Users completo por red."
    Warn "Si nadie lo usa, elimínalo con:  .\native\harden.ps1 -RemoveUsersShare"
}

# ── Checklist de acciones manuales ───────────────────────────────────────────
Step "PENDIENTES MANUALES (el script no puede hacerlos)"
Write-Host @"
   1. ROTAR credenciales expuestas (HT-01, hacerlo en este orden):
      a. PostgreSQL: nueva contraseña fuerte ->  ALTER USER generico WITH PASSWORD '<nueva>';
      b. Actualizar DB_PASSWORD en C:\BootWhatsapp\.env y redesplegar (deploy.ps1
         la copia al backend y vuelve a restringir permisos).
      c. Meta for Developers: regenerar WHATSAPP_API_TOKEN y WHATSAPP_APP_SECRET,
         actualizar .env. OJO: NO regenerar FERNET_KEY (rompe los tokens cifrados
         guardados en la BD).
   2. Superusuario Django (HT-02):
      .venv\Scripts\python manage.py changepassword admin   (contraseña fuerte y única)
   3. Windows Defender: habilitar Tamper Protection (Seguridad de Windows ->
      Antivirus -> Configuración -> Protección contra alteraciones) en AMBOS servidores.
   4. SERVIDOR-DB-PRI (HT-05): aplicar Windows Update pendiente (último parche 04/03/2026)
      y dejar un ciclo mensual de parcheo.
   5. PostgreSQL (O-01): en postgresql.conf poner listen_addresses = 'IP-privada'
      (no 0.0.0.0) y en el firewall permitir 5432 SOLO desde la IP del servidor de app.
   6. Retest del pentest a los 30 días.
"@
Write-Host ""
Write-Host "Listo. Revisa arriba los avisos en amarillo/rojo." -ForegroundColor Green
