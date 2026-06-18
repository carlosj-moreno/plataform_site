# ─────────────────────────────────────────────────────────────────────────────
# Backend Django (Python 3.14 + gunicorn + whitenoise)
# Build context: project root (so we can also COPY docker/backend/entrypoint.sh)
# ─────────────────────────────────────────────────────────────────────────────
FROM python:3.14-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONUTF8=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Runtime libs:
#   libpq5         — PostgreSQL client lib (psycopg2-binary fallback)
#   libjpeg / zlib / libfreetype — Pillow runtime
#   libglib2.0-0   — runtime de opencv-python-headless (lector de QR de facturas DIAN)
#   curl           — used by HEALTHCHECK
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq5 \
        libjpeg62-turbo \
        zlib1g \
        libfreetype6 \
        libglib2.0-0 \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ── Deps (separate layer for cache) ──────────────────────────────────────────
# Install pinned project deps first, then add prod-only extras that the repo's
# requirements.txt omits but settings.py actually requires (whitenoise) plus
# the WSGI server (gunicorn).
COPY Backend/bootwhatsapp/requirements.txt ./
RUN pip install -r requirements.txt \
 && pip install "gunicorn==23.0.0" "whitenoise==6.12.0" "cryptography>=46.0"

# ── App source ───────────────────────────────────────────────────────────────
COPY Backend/bootwhatsapp/ /app/
COPY docker/backend/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && mkdir -p /app/media /app/static_files

# Non-root user
RUN groupadd --system app && useradd --system --gid app --home /app app \
 && chown -R app:app /app
USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -fsS http://localhost:8000/api/schema/ >/dev/null || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "core.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "3", \
     "--threads", "4", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-"]
