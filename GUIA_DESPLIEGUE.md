# Guía de despliegue — BootWhatsapp (local, sin Docker)

Ejecuta la plataforma (Backend Django + Engine Node + Frontend React) **en local**
sobre Windows: tres procesos normales, **sin Docker, sin Caddy, sin servicios y
sin instalar software de terceros**.

---

## 1. Arquitectura

| Proceso | Tecnología | Puerto |
|---|---|---|
| Frontend | `native\serve.py` (Python stdlib): sirve `dist\` + proxy | 8080 ← se abre en el navegador |
| Backend | Django + waitress | 8000 (interno) |
| Engine | Node (whatsapp-web.js) | 3001 (interno) |

`serve.py` sirve el SPA y reenvía `/api`, `/media`, `/static` y `/webhook` al
backend. Todo queda en el **mismo origen** (`:8080`), así que la API y **los
documentos (`/media`) cargan** sin proxy externo ni CORS. **Solo se expone el
:8080**. **PostgreSQL es externo** (`localhost:5432`).

Este repo (`plataform_site`) solo trae la configuración; el código se clona en
`Backend/bootwhatsapp/` y `Frontend/bootwhatsapp_frontend/`.

---

## 2. Requisitos (deben existir; el script NO los instala)

- **Git**, **Node.js** (con `npm`), **Python 3.14** (`py -3.14`)
- **PostgreSQL** en `localhost` con BD/rol creados (§3)

```powershell
git --version ; node --version ; npm --version ; py -3.14 --version
Get-Service *postgre*    # debe existir y estar Running
```

---

## 3. PostgreSQL (externo)

Crea la BD y el rol una vez:
```sql
CREATE DATABASE bootwhatsapp;
CREATE USER bootwhatsapp_user WITH PASSWORD 'una-contraseña-fuerte';
GRANT ALL PRIVILEGES ON DATABASE bootwhatsapp TO bootwhatsapp_user;
\c bootwhatsapp
GRANT ALL ON SCHEMA public TO bootwhatsapp_user;
```
Usa esa misma contraseña en `DB_PASSWORD` del `.env`. Las migraciones se aplican
solas durante el despliegue.

---

## 4. Configuración (`deploy.config.ps1`)

Se crea sola la 1ª vez (desde `deploy.config.example.ps1`). Contiene repos, rama,
token y **los puertos**:
```powershell
$BackendRepo    = "https://github.com/carlosj-moreno/bootwhatsapp.git"
$FrontendRepo   = "https://github.com/carlosj-moreno/bootwhatsapp_frontend.git"
$BackendBranch  = "develop"
$FrontendBranch = "develop"
$GitHubToken    = "github_pat_..."   # para clonar sin login (recomendado en servidores)

$BackendPort  = 8000      # interno
$FrontendPort = 8080      # el unico puerto que se expone (la URL que abres)
$EnginePort   = 3001      # interno
```
> El frontend (`serve.py`) se ata a `0.0.0.0`, así que para abrirlo desde **otra
> PC** basta `http://<IP-del-servidor>:8080` (abre ese puerto en el firewall). No
> hay que reconstruir nada: la API y los documentos van por el mismo origen.

---

## 5. Secretos (`.env`)

Se crea solo la 1ª vez (desde `.env.native.example`). Obligatorios:

| Variable | Cómo obtenerla |
|----------|----------------|
| `SECRET_KEY` | `py -c "import secrets; print(secrets.token_urlsafe(64))"` |
| `DB_PASSWORD` | la contraseña del rol `bootwhatsapp_user` (§3) |
| `WHATSAPP_API_TOKEN` / `WHATSAPP_PHONE_NUMBER_ID` | Meta → tu App → WhatsApp → API Setup |
| `WHATSAPP_APP_SECRET` | Meta → Configuración básica |
| `META_VERIFY_TOKEN` | valor libre que repites en Meta → Webhooks |
| `GROQ_API_KEY` | https://console.groq.com/keys |
| `FERNET_KEY` | `py -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"` |
| `WHATSAPP_ENGINE_SECRET` | `py -c "import secrets; print(secrets.token_urlsafe(32))"` |

Importante: `DEBUG=False`, **`DB_HOST=localhost`**, `TOGETHER_API_KEY` (opcional,
para visión de imágenes/facturas).

> ⚠️ No regeneres `FERNET_KEY` si ya hay conexiones guardadas (rompe los tokens cifrados).

---

## 6. Desplegar — un solo comando

Doble clic en **`instalar.bat`** (o `powershell -ExecutionPolicy Bypass -File .\deploy.ps1`).

- **1ª vez:** crea `deploy.config.ps1` y `.env` y los abre. Complétalos y repite.
- **2ª vez:** clona/actualiza el código, copia el `.env`, crea el venv + dependencias,
  `migrate` + `collectstatic`, `npm ci` del engine, build del frontend, y **arranca**.

Al terminar: **http://localhost:8080**

### Superusuario (primera vez)
```powershell
& .\Backend\bootwhatsapp\.venv\Scripts\python.exe .\Backend\bootwhatsapp\manage.py createsuperuser
```

---

## 7. Manejo diario

```powershell
.\native\local.ps1 status     # estado de los 3
.\native\local.ps1 stop
.\native\local.ps1 start
.\deploy.ps1                  # redesplegar tras cambios de código
```
Logs: `logs\backend.err`, `logs\engine.err`, `logs\frontend.err`.

> Son procesos normales: se cierran al cerrar sesión/reiniciar. Vuelve a arrancar
> con `.\native\local.ps1 start`.

### Datos a NO borrar
- `Frontend\bootwhatsapp_frontend\engine\.wwebjs_auth\` (sesiones WhatsApp; si se
  borra hay que re-escanear el QR)
- `Backend\bootwhatsapp\media\` (adjuntos)
- la BD de PostgreSQL

---

## 8. Conectar el webhook de Meta

- **Callback URL:** `https://TU_DOMINIO/webhook` (HTTPS público apuntando al backend).
- **Verify Token:** el mismo de `META_VERIFY_TOKEN`.
- Suscribe la WABA (`subscribed_apps`) y el campo `messages`.

(Para exponer el backend a internet con HTTPS necesitas un túnel o un reverse-proxy
delante; eso queda fuera de este despliegue local.)

---

## 9. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| `Falta 'git'/'node'/'py'` | Instala el requisito (el script no instala software). |
| Backend no conecta a la BD | Postgres apagado o `DB_HOST`/`DB_PASSWORD` mal. |
| Falta una variable OBLIGATORIA | Complétala en `.env` (el script avisa cuál). |
| Puerto ocupado | Cambia `$BackendPort/$FrontendPort/$EnginePort` y re-ejecuta `.\deploy.ps1`. |
| El front carga pero no trae datos | Backend caído. Verifica `.\native\local.ps1 status` y que `http://localhost:8080/api/schema/` responda 200 (la API va por el mismo :8080 vía `serve.py`). |
| Los documentos no abren (404) | Que el backend esté UP; los `/media` los reenvía `serve.py`. Prueba `http://localhost:8080/media/...`. |
| Lo abro desde otra PC y no carga | Abre `http://<IP-del-servidor>:8080` y **permite el puerto 8080 en el firewall** de Windows. No hace falta reconstruir. |
| Engine pide QR cada reinicio | Se borró `engine\.wwebjs_auth\`. |

---

## Referencia rápida (de cero)

```powershell
git clone <url-plataform_site> ; cd plataform_site
# (asegurar Git, Node, Python 3.14 y PostgreSQL con la BD creada)
# doble clic instalar.bat  -> completa .env y deploy.config.ps1 -> repite
.\native\local.ps1 status
# abrir http://localhost:8080
```
