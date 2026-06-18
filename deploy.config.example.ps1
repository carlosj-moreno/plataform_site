# ─────────────────────────────────────────────────────────────────────────────
# Configuración del despliegue (Windows / PowerShell).
#   Copia este archivo a deploy.config.ps1 y edítalo:
#     Copy-Item deploy.config.example.ps1 deploy.config.ps1
#   deploy.config.ps1 está en .gitignore (no se sube).
# ─────────────────────────────────────────────────────────────────────────────

# URLs SSH de los repos privados. El servidor se autentica con una llave SSH
# (deploy key) de solo-lectura. Si configuraste alias por repo en ~/.ssh/config
# usa "git@github-backend:..." / "git@github-frontend:..."; si usas una sola
# llave de cuenta con acceso a ambos, deja "git@github.com:...".
$BackendRepo   = "git@github.com:carlosj-moreno/bootwhatsapp.git"
$FrontendRepo  = "git@github.com:carlosj-moreno/bootwhatsapp_frontend.git"

# Rama a desplegar (el trabajo activo está en develop).
$BackendBranch  = "develop"
$FrontendBranch = "develop"

# Carpetas destino — deben coincidir con el COPY de los Dockerfiles.
# La raíz de cada repo es el proyecto en sí, por eso se clona un nivel adentro.
$BackendDir   = "Backend/bootwhatsapp"
$FrontendDir  = "Frontend/bootwhatsapp_frontend"

# (Opcional) Llave SSH específica. Vacío = usa la llave por defecto / ssh-agent.
$SshKey = ""
