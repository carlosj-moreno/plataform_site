# shellcheck shell=sh
# ─────────────────────────────────────────────────────────────────────────────
# Configuración del despliegue — COPIA este archivo a deploy.config.sh y edítalo.
#   cp deploy.config.example.sh deploy.config.sh
# deploy.config.sh está en .gitignore (no se sube). Aquí van las URLs reales de
# los repositorios PRIVADOS de la app y la rama a desplegar.
# ─────────────────────────────────────────────────────────────────────────────

# URLs SSH de los repos privados (formato git@github.com:owner/repo.git).
# El servidor se autentica con una llave SSH (deploy key) de solo-lectura.
BACKEND_REPO="git@github.com:carlosj-moreno/REEMPLAZA-backend.git"
FRONTEND_REPO="git@github.com:carlosj-moreno/REEMPLAZA-frontend.git"

# Rama a desplegar de cada repo.
BACKEND_BRANCH="main"
FRONTEND_BRANCH="main"

# Carpetas destino (deben coincidir con lo que esperan los Dockerfiles):
#   - El Dockerfile del backend hace COPY Backend/bootwhatsapp/...
#     => el repo de Backend debe contener la carpeta "bootwhatsapp/" en su raíz.
#   - Los Dockerfiles de frontend/engine hacen COPY Frontend/bootwhatsapp_frontend/...
#     => el repo de Frontend debe contener "bootwhatsapp_frontend/" en su raíz.
BACKEND_DIR="Backend"
FRONTEND_DIR="Frontend"

# (Opcional) Llave SSH específica para clonar. Si se deja vacío se usa el
# ssh-agent / la llave por defecto (~/.ssh/id_ed25519). El passphrase de esta
# llave es "la clave" que se pide al desplegar si la llave no está en el agente.
SSH_KEY=""
