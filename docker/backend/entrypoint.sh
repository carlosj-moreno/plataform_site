#!/bin/sh
# ─────────────────────────────────────────────────────────────────────────────
# Backend entrypoint: wait for DB, run migrations, collect static, then exec CMD
# ─────────────────────────────────────────────────────────────────────────────
set -e

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"

echo "[entrypoint] waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}..."
# Pure-python TCP probe — no need for pg_isready / nc in the image
python - <<PYEOF
import os, socket, sys, time
host = os.environ.get("DB_HOST", "localhost")
port = int(os.environ.get("DB_PORT", "5432"))
deadline = time.time() + 60
while time.time() < deadline:
    try:
        with socket.create_connection((host, port), timeout=3):
            sys.exit(0)
    except OSError:
        time.sleep(2)
print(f"[entrypoint] timed out waiting for {host}:{port}", file=sys.stderr)
sys.exit(1)
PYEOF

echo "[entrypoint] applying migrations..."
python manage.py migrate --noinput

echo "[entrypoint] collecting static files..."
python manage.py collectstatic --noinput

echo "[entrypoint] launching: $*"
exec "$@"
