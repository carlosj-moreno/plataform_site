# Guía de despliegue — BootWhatsapp

Esta guía describe cómo desplegar la plataforma completa (Backend Django + Engine Node + Frontend React) usando Docker. Está pensada para un servidor nuevo, en **Windows** (Docker Desktop + PowerShell) o **Linux** (Docker Engine).

---

## 1. Arquitectura del stack

`docker compose` levanta tres servicios en una red interna (`botnet`):

| Servicio   | Imagen / tecnología                 | Puerto host | Rol |
|------------|-------------------------------------|-------------|-----|
| `frontend` | React + nginx                       | `8080→80`   | UI pública; sirve la app y hace proxy de `/api/` → backend |
| `backend`  | Django + gunicorn + whitenoise      | `8000→8000` | API REST, lógica de negocio, webhook de Meta |
| `engine`   | Node (whatsapp-web.js, Chromium)    | interno     | Sesiones de WhatsApp escaneadas por QR (no expuesto al host) |

**PostgreSQL es EXTERNO** — no lo levanta este compose. Debe existir una base de datos accesible (en el mismo host vía `host.docker.internal`, o un Postgres administrado).

**Repos de código separados.** Este repo (`plataform_site`) contiene SOLO la configuración de Docker. El código vive en dos repos privados que el script de despliegue clona automáticamente:
- Backend → `Backend/bootwhatsapp/`
- Frontend → `Frontend/bootwhatsapp_frontend/`

---

## 2. Requisitos previos

En el servidor:

- **Git** (en Windows, Git for Windows incluye el Administrador de Credenciales).
- **Docker** con `docker compose` v2 (Docker Desktop en Windows/Mac, o Docker Engine + plugin compose en Linux).
- **PostgreSQL accesible** con una base de datos y un rol ya creados (ver §3).
- Acceso de lectura a los dos repos privados (token PAT recomendado — ver §4).

Verifica las herramientas:

```powershell
git --version
docker --version
docker compose version
```

---

## 3. Preparar PostgreSQL (externo)

La app NO crea la base ni el rol. Créalos una vez:

```sql
CREATE DATABASE bootwhatsapp;
CREATE USER bootwhatsapp_user WITH PASSWORD 'una-contraseña-fuerte';
GRANT ALL PRIVILEGES ON DATABASE bootwhatsapp TO bootwhatsapp_user;
-- En Postgres 15+ además:
\c bootwhatsapp
GRANT ALL ON SCHEMA public TO bootwhatsapp_user;
```

- Si Postgres corre en el **mismo host** que Docker → `DB_HOST=host.docker.internal` (el compose ya añade el `extra_hosts` necesario).
- Si es un Postgres **administrado / remoto** → usa su endpoint real en `DB_HOST`.
- Asegúrate de que `pg_hba.conf` permita la conexión desde la IP del contenedor/host.

> Las **migraciones se aplican solas** al arrancar el backend (el entrypoint corre `migrate` y `collectstatic`). No hay que ejecutarlas a mano.

---

## 4. Configurar el acceso a los repos privados

Copia el archivo de configuración de despliegue y edítalo. **No se versiona** (está en `.gitignore`), así que es portátil entre máquinas.

**Windows (PowerShell):**
```powershell
Copy-Item deploy.config.example.ps1 deploy.config.ps1
```

**Linux:**
```sh
cp deploy.config.example.sh deploy.config.sh
```

Dentro define las URLs, la rama y — recomendado para servidores — un **GitHub Personal Access Token (fine-grained)** con acceso de solo lectura (`Contents: Read-only`) a los dos repos. Con el token, el clonado funciona sin abrir navegador:

```powershell
# deploy.config.ps1
$BackendRepo    = "https://github.com/carlosj-moreno/bootwhatsapp.git"
$FrontendRepo   = "https://github.com/carlosj-moreno/bootwhatsapp_frontend.git"
$BackendBranch  = "develop"      # rama de trabajo activo
$FrontendBranch = "develop"
$BackendDir     = "Backend/bootwhatsapp"
$FrontendDir    = "Frontend/bootwhatsapp_frontend"
$GitHubToken    = "github_pat_..."   # vacío = login interactivo por navegador
$SshKey         = ""                  # opcional, solo si usas URLs SSH
```

> El token se inyecta solo para clonar y **no queda guardado** en `.git/config` (el script restaura la URL limpia). Si lo dejas vacío en Windows, Git pedirá login a GitHub la primera vez y lo cachea en el Credential Manager.

---

## 5. Configurar los secretos (`.env`)

Copia la plantilla y rellena los valores reales. **Nunca se versiona.**

```powershell
Copy-Item .env.docker.example .env     # Windows
# cp .env.docker.example .env          # Linux
```

Variables **OBLIGATORIAS** (el backend no arranca sin ellas):

| Variable | Cómo obtenerla |
|----------|----------------|
| `SECRET_KEY` | `python -c "import secrets; print(secrets.token_urlsafe(64))"` |
| `DB_PASSWORD` | la contraseña del rol `bootwhatsapp_user` (§3) |
| `WHATSAPP_API_TOKEN` | Meta Developers → tu App → WhatsApp → API Setup |
| `WHATSAPP_PHONE_NUMBER_ID` | mismo panel (el del **número**, no la WABA) |
| `WHATSAPP_APP_SECRET` | Meta → Configuración básica (valida la firma del webhook) |
| `META_VERIFY_TOKEN` | string libre que defines y repites en Meta → Webhooks |
| `GROQ_API_KEY` | https://console.groq.com/keys (proveedor principal de texto) |
| `FERNET_KEY` | `python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"` |
| `WHATSAPP_ENGINE_SECRET` | `python -c "import secrets; print(secrets.token_urlsafe(32))"` (compartido backend↔engine) |

Variables importantes adicionales:

- `DEBUG=False` en producción.
- `ALLOWED_HOSTS` → tu dominio + `localhost,127.0.0.1,frontend`.
- `CSRF_TRUSTED_ORIGINS` → con dominio real y HTTPS, pon `https://tudominio.com`.
- `DB_HOST` / `DB_NAME` / `DB_USER` / `DB_PORT` → según §3.
- `TOGETHER_API_KEY` (opcional pero recomendado): respaldo de texto + **visión de imágenes** (facturas DIAN, validación de documentos). Sin ella no se procesan imágenes.
- `INTEGRATION_SALT` (opcional): solo si usas el gateway de Aliados.

> ⚠️ **NUNCA regeneres `FERNET_KEY`** si ya hay conexiones de WhatsApp guardadas: cifra los tokens en la BD y cambiarla los vuelve ilegibles (error 401 de Meta silencioso).

---

## 6. Desplegar

Desde la raíz del repo:

**Windows (PowerShell):**
```powershell
.\deploy.ps1
# Si PowerShell bloquea el script:
powershell -ExecutionPolicy Bypass -File .\deploy.ps1
```

**Linux:**
```sh
./deploy.sh
```

El script:
1. Clona o actualiza `Backend/` y `Frontend/` desde los repos privados (rama configurada).
2. Verifica que exista `.env`.
3. Construye y levanta el stack: `docker compose up -d --build`.

Al terminar:
- **Frontend:** http://localhost:8080
- **Backend directo** (solo debug): http://localhost:8000
- **Logs:** `docker compose logs -f backend`

### Crear el superusuario (primera vez)

```powershell
docker compose exec backend python manage.py createsuperuser
```

---

## 7. Conectar el webhook de Meta

Para que un número responda hacen falta 5 eslabones (ver detalle en la nota de onboarding del proyecto). En el panel de Meta → tu App → WhatsApp → Configuración:

- **Callback URL:** `https://TU_DOMINIO/api/whatsapp/webhook/` (debe ser HTTPS público).
- **Verify Token:** el mismo valor de `META_VERIFY_TOKEN`.
- Suscribe la WABA a la app (`subscribed_apps`) y suscribe el campo `messages`.

En local/pruebas se usa un dev tunnel efímero como callback. La gestión de credenciales por número se hace en la UI: **Números Puente → ✎ Editar credenciales**.

---

## 8. Operación diaria

```powershell
# Estado de los servicios
docker compose ps

# Logs en vivo
docker compose logs -f backend
docker compose logs -f engine
docker compose logs -f frontend

# Redesplegar tras un cambio de código (vuelve a clonar la rama y reconstruye)
.\deploy.ps1

# Reconstruir un solo servicio sin re-clonar
docker compose up -d --build backend

# Reinicio limpio si algo queda en mal estado
docker compose up -d --force-recreate

# Parar / arrancar
docker compose down
docker compose up -d
```

> El código **no está bind-mounteado**: tras editar archivos `.py` / `.jsx` hay que **reconstruir** (`docker compose up -d --build backend frontend`). Si no, "no se ve el cambio".

### Volúmenes persistentes (NO borrar)

| Volumen / mount | Contiene | Riesgo si se pierde |
|-----------------|----------|---------------------|
| `engine_sessions` (`/app/.wwebjs_auth`) | sesiones de WhatsApp escaneadas | hay que **re-escanear el QR** |
| `./Backend/bootwhatsapp/media` (bind) | adjuntos de WhatsApp | se pierden los archivos |
| `vision_cache` | extracciones de visión (Qwen) | se re-paga la extracción |
| `backend_static` | estáticos recolectados | se regeneran solos |

> `docker compose down -v` **borra los volúmenes** (incluidas las sesiones de WhatsApp). Úsalo con cuidado. La media sobrevive porque es un bind-mount al host.

---

## 9. Resolución de problemas

| Síntoma | Causa probable / solución |
|---------|---------------------------|
| Backend no arranca, "timed out waiting for DB" | Postgres no accesible. Revisa `DB_HOST` (¿`host.docker.internal`?), `pg_hba.conf`, firewall. |
| Backend lanza error por variable faltante | Falta una `(OBLIGATORIA)` en `.env`. |
| Webhook de Meta devuelve 401 / firma inválida | `WHATSAPP_APP_SECRET` incorrecto, o `FERNET_KEY` regenerada (tokens ilegibles). |
| Imágenes/facturas no se procesan | Falta `TOGETHER_API_KEY` (la visión depende de Together.ai). |
| Engine pide QR cada reinicio | Se perdió el volumen `engine_sessions` (no uses `down -v`). |
| Fuentes externas fallan intermitente ("No address associated") | DNS de Docker; el compose ya fuerza `1.1.1.1`/`8.8.8.8` en el backend. |
| Cambio de código "no se ve" | Falta reconstruir: `docker compose up -d --build`. |
| `git clone` pide login en bucle | Configura `$GitHubToken` en `deploy.config.ps1`. |

---

## Referencia rápida (servidor nuevo, de cero)

```powershell
# 1. Clonar este repo de config
git clone <url-de-plataform_site> ; cd plataform_site

# 2. Config de despliegue + secretos
Copy-Item deploy.config.example.ps1 deploy.config.ps1   # editar URLs/branch/token
Copy-Item .env.docker.example .env                       # editar secretos

# 3. (Asegurar que Postgres externo existe — §3)

# 4. Desplegar
.\deploy.ps1

# 5. Superusuario (primera vez)
docker compose exec backend python manage.py createsuperuser
```
