# shellcheck shell=sh
# ─────────────────────────────────────────────────────────────────────────────
# Configuración del despliegue — COPIA este archivo a deploy.config.sh y edítalo.
#   cp deploy.config.example.sh deploy.config.sh
# deploy.config.sh está en .gitignore (no se sube). Aquí van las URLs reales de
# los repositorios PRIVADOS de la app y la rama a desplegar.
# ─────────────────────────────────────────────────────────────────────────────

# URLs de los repos privados.
# Por defecto HTTPS: git pide credenciales la primera vez (Git Credential Manager
# en Windows abre el navegador; en Linux usa un token/PAT) y las cachea. Como los
# repos son tuyos, tienes acceso completo. No requiere llaves SSH.
BACKEND_REPO="https://github.com/carlosj-moreno/bootwhatsapp.git"
FRONTEND_REPO="https://github.com/carlosj-moreno/bootwhatsapp_frontend.git"
# Alternativa SSH (deploy keys): "git@github.com:carlosj-moreno/bootwhatsapp.git"

# Rama a desplegar de cada repo (los repos tienen main y develop).
# El trabajo activo está en develop.
BACKEND_BRANCH="develop"
FRONTEND_BRANCH="develop"

# Carpetas destino — deben coincidir EXACTAMENTE con lo que copian los Dockerfiles.
#   - backend  : COPY Backend/bootwhatsapp/...        (manage.py está en la raíz
#                 del repo "bootwhatsapp", así que se clona dentro de bootwhatsapp/)
#   - frontend : COPY Frontend/bootwhatsapp_frontend/...
#   - engine   : COPY Frontend/bootwhatsapp_frontend/engine/...  (viene en el repo
#                 del frontend, no es un repo aparte)
BACKEND_DIR="Backend/bootwhatsapp"
FRONTEND_DIR="Frontend/bootwhatsapp_frontend"

# (Opcional) Llave SSH específica para clonar. Si se deja vacío se usa el
# ssh-agent / la llave por defecto (~/.ssh/id_ed25519). El passphrase de esta
# llave es "la clave" que se pide al desplegar si la llave no está en el agente.
SSH_KEY=""
