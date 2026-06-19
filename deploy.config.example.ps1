# ─────────────────────────────────────────────────────────────────────────────
# Configuración del despliegue (Windows / PowerShell).
#   Copia este archivo a deploy.config.ps1 y edítalo:
#     Copy-Item deploy.config.example.ps1 deploy.config.ps1
#   deploy.config.ps1 está en .gitignore (no se sube).
# ─────────────────────────────────────────────────────────────────────────────

# URLs de los repos privados.
# Por defecto HTTPS: el Administrador de Credenciales de Git (viene con Git for
# Windows) pide login a GitHub la PRIMERA vez (ventana del navegador) y lo cachea.
# Como los repos son tuyos, tienes acceso completo. No requiere llaves SSH.
$BackendRepo   = "https://github.com/carlosj-moreno/bootwhatsapp.git"
$FrontendRepo  = "https://github.com/carlosj-moreno/bootwhatsapp_frontend.git"
# Alternativa SSH (si prefieres deploy keys): usa
#   "git@github.com:carlosj-moreno/bootwhatsapp.git"  (+ ~/.ssh/config con la llave)

# Rama a desplegar (el trabajo activo está en develop).
$BackendBranch  = "develop"
$FrontendBranch = "develop"

# Carpetas destino — deben coincidir con el COPY de los Dockerfiles.
# La raíz de cada repo es el proyecto en sí, por eso se clona un nivel adentro.
$BackendDir   = "Backend/bootwhatsapp"
$FrontendDir  = "Frontend/bootwhatsapp_frontend"

# ─── Acceso sin login interactivo (recomendado para servidores / varias máquinas) ───
# Pega aquí un GitHub Personal Access Token (fine-grained) con permiso
#   Repository access: los 2 repos  +  Contents: Read-only
# Así el clone funciona solo, sin abrir navegador. Este archivo (deploy.config.ps1)
# está en .gitignore, por eso el token no se sube. Para una máquina nueva:
# copia deploy.config.ps1 + .env y ejecuta .\deploy.ps1.
# Déjalo vacío para usar el login interactivo del navegador (Credential Manager).
$GitHubToken = ""

# (Opcional) Llave SSH específica. Vacío = usa la llave por defecto / ssh-agent.
$SshKey = ""
