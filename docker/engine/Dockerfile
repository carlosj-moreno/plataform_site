# ─────────────────────────────────────────────────────────────────────────────
# WhatsApp Engine (Node.js + whatsapp-web.js + Chromium headless)
# Build context: project root
# ─────────────────────────────────────────────────────────────────────────────
# node:22-slim is Debian 13 (trixie). Avoids the bookworm-security DNS flakiness
# observed inside Docker Desktop's WSL2 VM during apt-get update.
FROM node:22-slim AS base

ENV NODE_ENV=production \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    CHROME_BIN=/usr/bin/chromium

# System Chromium + minimal extras. The `chromium` package declares all its
# runtime libs (libnss3, libgbm1, libxkbcommon0, …) as Depends, so apt pulls
# them automatically — no need to hand-list each one (which breaks across
# Debian versions due to the t64 rename migration in trixie).
#
# Acquire::Retries protects against intermittent DNS failures inside Docker
# Desktop's WSL2 VM (Could not resolve 'deb.debian.org').
# Acquire::Retries protects against intermittent DNS failures inside Docker
# Desktop's WSL2 VM (Could not resolve 'deb.debian.org').
RUN echo 'Acquire::Retries "5"; Acquire::http::Timeout "30"; Acquire::https::Timeout "30";' \
        > /etc/apt/apt.conf.d/80-retries \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        chromium \
        ca-certificates \
        fonts-liberation \
        wget \
        dumb-init \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ── Deps (separate layer for cache) ──────────────────────────────────────────
COPY Frontend/bootwhatsapp_frontend/engine/package.json \
     Frontend/bootwhatsapp_frontend/engine/package-lock.json* \
     ./
RUN npm ci --omit=dev

# ── App source ───────────────────────────────────────────────────────────────
COPY Frontend/bootwhatsapp_frontend/engine/ /app/

# whatsapp-web.js persists sessions here (LocalAuth → AUTH_PATH in whatsappClient.js).
# docker-compose mounts a named volume on this path so QR scans survive restarts.
RUN mkdir -p /app/.wwebjs_auth

# Run as non-root. Chromium under --no-sandbox tolerates this (already passed in
# whatsappClient.js puppeteer args).
RUN groupadd --system app && useradd --system --gid app --home /app app \
 && chown -R app:app /app
USER app

EXPOSE 3001

# dumb-init reaps zombie chromium processes if puppeteer crashes mid-flight
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "app.js"]
