# ─────────────────────────────────────────────────────────────────────────────
# Frontend React (Vite build → nginx static)
# Build context: project root
# ─────────────────────────────────────────────────────────────────────────────

# ── Stage 1: build with Vite ─────────────────────────────────────────────────
FROM node:20-slim AS build

WORKDIR /app

# VITE_* vars are baked into the bundle at build time.
# Default to relative /api so nginx can proxy to the backend without hard-
# coding a hostname; override via --build-arg if pointing to an external API.
ARG VITE_API_URL=/api
ARG VITE_WS_URL=
ARG VITE_POLLING_INTERVAL=5000
ARG VITE_APP_ENV=production

ENV VITE_API_URL=$VITE_API_URL \
    VITE_WS_URL=$VITE_WS_URL \
    VITE_POLLING_INTERVAL=$VITE_POLLING_INTERVAL \
    VITE_APP_ENV=$VITE_APP_ENV

COPY Frontend/bootwhatsapp_frontend/package.json \
     Frontend/bootwhatsapp_frontend/package-lock.json* \
     ./
RUN npm ci

# Copy only the build inputs (skip node-side engine/, node_modules/, dist/)
COPY Frontend/bootwhatsapp_frontend/index.html ./
COPY Frontend/bootwhatsapp_frontend/vite.config.js ./
COPY Frontend/bootwhatsapp_frontend/postcss.config.js ./
COPY Frontend/bootwhatsapp_frontend/tailwind.config.js ./
COPY Frontend/bootwhatsapp_frontend/eslint.config.js ./
COPY Frontend/bootwhatsapp_frontend/public/ ./public/
COPY Frontend/bootwhatsapp_frontend/src/ ./src/

RUN npm run build

# ── Stage 2: nginx serves the static bundle + reverse-proxies the API ────────
FROM nginx:1.27-alpine AS runtime

COPY docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget -q -O- http://127.0.0.1/healthz || exit 1
