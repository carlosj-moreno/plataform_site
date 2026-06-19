# Despliegue con Docker — BootWhatsapp

Stack: **Backend Django** + **Engine Node (whatsapp-web.js + Chromium)** + **Frontend React (nginx)**.
La **base de datos PostgreSQL es externa** (host o servicio administrado), no se levanta en este compose.

---

## 1. Requisitos

- Docker Engine ≥ 24 y `docker compose` plugin (ya viene con Docker Desktop).
- PostgreSQL 18 accesible desde el contenedor del backend, con:
  - BD `bootwhatsapp` y rol `bootwhatsapp_user` provisionados (`Backend/bootwhatsapp/docs/setup_postgres.sql`).
  - Extensión `pg_trgm` habilitada en la BD.

---

## 2. Configurar `.env`

Desde la raíz del repo:

```bash
cp .env.docker.example .env
```

Editar `.env` con los valores reales. **Variables obligatorias** (sin ellas el backend no arranca):

| Variable | Cómo generarla / dónde sacarla |
|---|---|
| `SECRET_KEY` | `python -c "import secrets; print(secrets.token_urlsafe(64))"` |
| `DB_PASSWORD` | El password del rol `bootwhatsapp_user` en tu Postgres |
| `WHATSAPP_API_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`, `META_VERIFY_TOKEN`, `WHATSAPP_APP_SECRET` | Meta Developers → tu App → WhatsApp |
| `GROQ_API_KEY` | Provider de IA principal → https://console.groq.com/keys |
| `WHATSAPP_ENGINE_SECRET` | Cualquier string largo aleatorio — backend y engine lo comparten |

Recomendadas (la app arranca sin ellas, pero faltan funciones):

| Variable | Para qué |
|---|---|
| `FERNET_KEY` | Cifra el access_token de las conexiones en la BD. `python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"` — **no la cambies** si ya hay conexiones guardadas |
| `TOGETHER_API_KEY` | Visión de imágenes (facturas DIAN, validación de documentos) + respaldo de texto |
| `INTEGRATION_SALT` | Solo si usas el gateway de Aliados. `python -c "import secrets; print(secrets.token_urlsafe(48))"` |

**`DB_HOST` según dónde corra Postgres:**

- Postgres en el host Windows/Mac: `DB_HOST=host.docker.internal` (ya configurado por defecto en el `.env.docker.example`).
- Postgres administrado (RDS, DO, etc.): `DB_HOST=tu.endpoint.com`.
- Postgres en otro contenedor: usar su nombre de servicio + conectarlo a la red `bootwhatsapp_botnet`.

> En Linux, `host.docker.internal` funciona gracias a `extra_hosts: host-gateway` configurado en el compose.

---

## 3. Levantar el stack

```bash
docker compose up -d --build
```

Acceso:

| Servicio | URL desde host | URL interna entre contenedores |
|---|---|---|
| Frontend (nginx + proxy al API) | http://localhost:8080 | `http://frontend:80` |
| Backend (directo, para debug) | http://localhost:8000 | `http://backend:8000` |
| Engine (no expuesto al host) | — | `http://engine:3001` |

El frontend ya está configurado para hablarle al backend vía `/api/` (nginx hace de proxy), así que **toda la app funciona desde `http://localhost:8080`**.

---

## 4. Operación

```bash
# Ver logs en vivo
docker compose logs -f backend
docker compose logs -f engine
docker compose logs -f frontend

# Ejecutar comandos de Django
docker compose exec backend python manage.py createsuperuser
docker compose exec backend python manage.py migrate
docker compose exec backend python manage.py shell

# Reiniciar solo un servicio
docker compose restart backend

# Bajar todo (mantiene volúmenes)
docker compose down

# Bajar todo y BORRAR sesiones de WhatsApp + media (destructivo)
docker compose down -v
```

---

## 5. Persistencia (volúmenes)

| Volumen | Contenido | Qué pasa si se borra |
|---|---|---|
| `bootwhatsapp_engine_sessions` | Carpetas `.wwebjs_auth/session-conn_*` | Hay que **re-escanear el QR** de cada conexión |
| `bootwhatsapp_backend_media` | Uploads del CRM (recibos, imágenes) | Se pierden los archivos subidos |
| `bootwhatsapp_backend_static` | `collectstatic` (admin assets) | Se regenera en cada `up` |

Backup recomendado del volumen del engine:

```bash
docker run --rm -v bootwhatsapp_engine_sessions:/data -v "$PWD":/backup alpine \
  tar czf /backup/engine_sessions_$(date +%F).tgz -C /data .
```

---

## 6. Webhook de Meta (producción)

Meta exige HTTPS público. Opciones:

1. **Reverse proxy externo** (Cloudflare, nginx host, Caddy) terminando TLS y enviando a `localhost:8080`. El nginx interno ya ruta `/webhook` al backend.
2. **Túnel para pruebas**: `cloudflared tunnel --url http://localhost:8080` o `ngrok http 8080`, y registrar la URL HTTPS resultante en Meta Developers → Webhooks (`/webhook` o `/api/chat/webhook/whatsapp/`).

---

## 7. Diagnóstico rápido

| Síntoma | Causa probable |
|---|---|
| Backend reinicia con `WHATSAPP_ENGINE_SECRET no está definido` | Falta el valor en `.env` (o tipo en la variable) |
| Backend reinicia con `connection refused` a la DB | `DB_HOST` mal configurado; probar `host.docker.internal` |
| Engine arranca pero el QR nunca aparece | Falta memoria para Chromium — subir `shm_size` en el compose |
| Frontend carga pero el login da `Network Error` | nginx no llega al backend — `docker compose logs frontend` para ver el upstream |
| `GET /api/schema/` devuelve 502 desde el frontend | El healthcheck del backend está fallando; revisar `docker compose ps` |

---

## 8. Producción — checklist mínima

- [ ] `DEBUG=False` en `.env`
- [ ] `ALLOWED_HOSTS` con tu dominio real (no `*`)
- [ ] `CSRF_TRUSTED_ORIGINS` con `https://tudominio.com`
- [ ] TLS terminando en un reverse proxy delante del puerto 8080
- [ ] `FERNET_KEY` guardada fuera del repo (no perderla → desencripta tokens existentes)
- [ ] Backups regulares del volumen `engine_sessions` y de la BD Postgres externa
- [ ] Revisar logs de `engine` la primera semana — Chromium a veces necesita más RAM bajo carga real
