# ─────────────────────────────────────────────────────────────────────────────
# deploy.ps1 — Despliegue en un servidor WINDOWS (Docker Desktop + PowerShell).
#
# Este repo (plataform_site) NO contiene el código de la app. Este script:
#   1. Clona o actualiza Backend/ y Frontend/ desde sus repos privados por SSH
#      (si la llave tiene passphrase, git la pedirá = "la clave").
#   2. Verifica que exista .env (secretos reales — nunca versionado).
#   3. Construye y levanta el stack con docker compose.
#
# Uso (PowerShell, desde la carpeta del repo):
#   Copy-Item deploy.config.example.ps1 deploy.config.ps1   # editar URLs/branch
#   Copy-Item .env.docker.example .env                       # editar secretos
#   .\deploy.ps1
#
# Si PowerShell bloquea el script:
#   powershell -ExecutionPolicy Bypass -File .\deploy.ps1
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

# ── 1. Cargar configuración ──────────────────────────────────────────────────
if (-not (Test-Path ".\deploy.config.ps1")) {
    Write-Host "X Falta deploy.config.ps1." -ForegroundColor Red
    Write-Host "  Copy-Item deploy.config.example.ps1 deploy.config.ps1   # y edita las URLs"
    exit 1
}
. .\deploy.config.ps1

foreach ($v in "BackendRepo","FrontendRepo","BackendBranch","FrontendBranch","BackendDir","FrontendDir") {
    if (-not (Get-Variable -Name $v -ValueOnly -ErrorAction SilentlyContinue)) {
        Write-Host "X Falta `$$v en deploy.config.ps1" -ForegroundColor Red; exit 1
    }
}

if ($SshKey) {
    $env:GIT_SSH_COMMAND = "ssh -i `"$SshKey`" -o IdentitiesOnly=yes"
}

# Token opcional para clonar por HTTPS sin login interactivo (portátil).
if (-not (Get-Variable -Name GitHubToken -ValueOnly -ErrorAction SilentlyContinue)) { $GitHubToken = "" }
function Get-AuthUrl($url) {
    if ($GitHubToken -and $url -like "https://*") {
        return ($url -replace '^https://', "https://x-access-token:$GitHubToken@")
    }
    return $url
}

# ── 2. Comprobar herramientas ────────────────────────────────────────────────
foreach ($tool in "git","docker") {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "X No se encontró '$tool' en PATH." -ForegroundColor Red; exit 1
    }
}

# ── 3. Clonar o actualizar los repos privados ────────────────────────────────
function Sync-Repo($repo, $branch, $dir) {
    $auth = Get-AuthUrl $repo
    if (Test-Path (Join-Path $dir ".git")) {
        Write-Host "-> Actualizando $dir ($branch)..." -ForegroundColor Cyan
        git -C $dir fetch --depth 1 $auth $branch
        if ($LASTEXITCODE -ne 0) { throw "git fetch falló para $dir" }
        git -C $dir checkout -B $branch FETCH_HEAD
    } else {
        Write-Host "-> Clonando $repo -> $dir ($branch)..." -ForegroundColor Cyan
        if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
        git clone --depth 1 --branch $branch $auth $dir
        if ($LASTEXITCODE -ne 0) { throw "git clone falló para $dir" }
        # No dejar el token guardado en .git/config:
        if ($GitHubToken) { git -C $dir remote set-url origin $repo }
    }
    if ($LASTEXITCODE -ne 0) { throw "git falló para $dir" }
}

Sync-Repo $BackendRepo  $BackendBranch  $BackendDir
Sync-Repo $FrontendRepo $FrontendBranch $FrontendDir

# ── 4. Verificar secretos ────────────────────────────────────────────────────
if (-not (Test-Path ".\.env")) {
    Write-Host "X Falta .env (secretos reales)." -ForegroundColor Red
    Write-Host "  Copy-Item .env.docker.example .env   # y complétalo (SECRET_KEY, DB_PASSWORD, FERNET_KEY, ...)"
    exit 1
}

# ── 5. Construir y levantar ──────────────────────────────────────────────────
Write-Host "-> docker compose up -d --build ..." -ForegroundColor Cyan
docker compose up -d --build
if ($LASTEXITCODE -ne 0) { throw "docker compose falló" }

Write-Host ""
Write-Host "OK Despliegue completo." -ForegroundColor Green
Write-Host "   Frontend: http://localhost:8080   |   logs: docker compose logs -f backend"
