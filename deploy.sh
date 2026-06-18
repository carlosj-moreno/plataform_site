#!/bin/sh
# ─────────────────────────────────────────────────────────────────────────────
# deploy.sh — Despliegue en el SERVIDOR a partir de SOLO la config de Docker.
#
# Este repo (plataform_site) NO contiene el código de la app. Este script:
#   1. Asegura acceso SSH a los repos privados (pide la clave/passphrase de la
#      llave SSH si hace falta cargarla en el agente).
#   2. Clona o actualiza Backend/ y Frontend/ desde sus repos privados.
#   3. Verifica que exista .env (secretos reales — nunca versionado).
#   4. Construye y levanta el stack con docker compose.
#
# Uso:
#   cp deploy.config.example.sh deploy.config.sh   # editar URLs/branch reales
#   cp .env.docker.example .env                     # editar secretos reales
#   ./deploy.sh
# ─────────────────────────────────────────────────────────────────────────────
set -eu

cd "$(dirname "$0")"

# ── 1. Cargar configuración ──────────────────────────────────────────────────
if [ -f deploy.config.sh ]; then
    # shellcheck disable=SC1091
    . ./deploy.config.sh
else
    echo "✖ Falta deploy.config.sh."
    echo "  cp deploy.config.example.sh deploy.config.sh   # y edita las URLs"
    exit 1
fi

: "${BACKEND_REPO:?Define BACKEND_REPO en deploy.config.sh}"
: "${FRONTEND_REPO:?Define FRONTEND_REPO en deploy.config.sh}"
BACKEND_BRANCH="${BACKEND_BRANCH:-main}"
FRONTEND_BRANCH="${FRONTEND_BRANCH:-main}"
BACKEND_DIR="${BACKEND_DIR:-Backend}"
FRONTEND_DIR="${FRONTEND_DIR:-Frontend}"

case "$BACKEND_REPO$FRONTEND_REPO" in
    *REEMPLAZA*)
        echo "✖ Edita deploy.config.sh: las URLs siguen con el placeholder REEMPLAZA-*."
        exit 1
        ;;
esac

# ── 2. Acceso SSH a los repos privados ───────────────────────────────────────
# Si se indicó una llave específica, úsala para todas las operaciones git.
if [ -n "${SSH_KEY:-}" ]; then
    export GIT_SSH_COMMAND="ssh -i $SSH_KEY -o IdentitiesOnly=yes"
fi

echo "→ Verificando acceso SSH a GitHub..."
# `ssh -T git@github.com` devuelve 1 incluso cuando la auth es correcta
# (GitHub no da shell), por eso miramos el mensaje, no el código de salida.
ssh_out=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
case "$ssh_out" in
    *"successfully authenticated"*)
        echo "  ✓ SSH OK"
        ;;
    *)
        echo "  ! La llave SSH no está disponible para el agente."
        echo "    Cargándola con ssh-add (te pedirá la clave/passphrase)..."
        # Esto es "pedir la clave": el passphrase de la deploy key.
        if [ -n "${SSH_KEY:-}" ]; then
            ssh-add "$SSH_KEY"
        else
            ssh-add
        fi
        ;;
esac

# ── 3. Clonar o actualizar los repos privados ────────────────────────────────
sync_repo() {
    repo="$1"; branch="$2"; dir="$3"
    if [ -d "$dir/.git" ]; then
        echo "→ Actualizando $dir ($branch)..."
        git -C "$dir" fetch --depth 1 origin "$branch"
        git -C "$dir" checkout -f "$branch"
        git -C "$dir" reset --hard "origin/$branch"
    else
        echo "→ Clonando $repo → $dir ($branch)..."
        rm -rf "$dir"
        git clone --depth 1 --branch "$branch" "$repo" "$dir"
    fi
}

sync_repo "$BACKEND_REPO"  "$BACKEND_BRANCH"  "$BACKEND_DIR"
sync_repo "$FRONTEND_REPO" "$FRONTEND_BRANCH" "$FRONTEND_DIR"

# ── 4. Verificar secretos ────────────────────────────────────────────────────
if [ ! -f .env ]; then
    echo "✖ Falta .env (secretos reales)."
    echo "  cp .env.docker.example .env   # y complétalo (SECRET_KEY, DB_PASSWORD, FERNET_KEY, ...)"
    exit 1
fi

# ── 5. Construir y levantar ──────────────────────────────────────────────────
echo "→ docker compose up -d --build ..."
docker compose up -d --build

echo ""
echo "✓ Despliegue completo."
echo "  Frontend: http://localhost:8080   |   logs: docker compose logs -f backend"
