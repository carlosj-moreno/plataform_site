# plataform_site — Despliegue local (Windows, sin Docker)

Configuración para **ejecutar BootWhatsapp en local** (en tu PC o tu servidor
Windows) **sin Docker, sin Caddy, sin servicios y sin instalar software de
terceros**. Solo usa lo que ya tienes: **Git, Node.js y Python**.

El código de la app vive en repos privados que se clonan:
- Backend Django → `github.com/carlosj-moreno/bootwhatsapp` → `Backend/bootwhatsapp/`
- Frontend React + engine → `github.com/carlosj-moreno/bootwhatsapp_frontend` → `Frontend/bootwhatsapp_frontend/`

## Cómo corre

Tres procesos normales (sin servicios). **Solo se usa el puerto del frontend (8080)**;
el backend y el engine quedan internos:

| Proceso | Tecnología | Puerto |
|---|---|---|
| **Frontend** | `native\serve.py` (Python stdlib): sirve el build **y** hace de proxy | **8080** ← abre esto |
| **Backend** | Django + waitress | 8000 (interno) |
| **Engine** | Node (WhatsApp) | 3001 (interno) |

`serve.py` reenvía `/api`, `/media`, `/static` y `/webhook` al backend, así que el
frontend, la API y **los documentos (`/media`) están en el mismo origen** → cargan
sin proxy externo y sin depender de CORS. **PostgreSQL es externo** en `localhost:5432`.

## Requisitos (deben existir; no se instalan solos)

- **Git**, **Node.js** (con `npm`), **Python 3.14** (`py -3.14`)
- **PostgreSQL** corriendo en `localhost` con la BD/rol creados

## Uso — un solo comando

```powershell
git clone https://github.com/carlosj-moreno/plataform_site.git
cd plataform_site
```
Luego **doble clic en `instalar.bat`** (o `powershell -ExecutionPolicy Bypass -File .\deploy.ps1`).

- **1ª vez:** crea `deploy.config.ps1` y `.env` (desde los `.example`) y los abre
  para que los completes. Llénalos y vuelve a ejecutar.
- **2ª vez:** clona/actualiza el código, copia el `.env`, crea el venv del backend
  e instala dependencias, corre `migrate` + `collectstatic`, hace `npm ci` del
  engine, construye el frontend, y **arranca los 3 procesos**.

Al terminar: **http://localhost:8080**

## Asignar los puertos

En `deploy.config.ps1`:
```powershell
$BackendPort  = 8000     # Django (interno)
$FrontendPort = 8080     # la URL que abres
$EnginePort   = 3001     # interno
```
La API y los documentos van **relativos** (mismo origen vía `serve.py`), así que
funciona igual desde otra PC abriendo `http://<IP-del-servidor>:8080` — no hay que
re-construir el frontend al cambiar de host. Si cambias los puertos, vuelve a
correr `.\deploy.ps1` (o `.\native\local.ps1 stop` + `start`).

## Manejo diario

```powershell
.\native\local.ps1 status     # estado de los 3
.\native\local.ps1 stop       # detener
.\native\local.ps1 start      # arrancar
```
Logs en `logs\backend.err`, `logs\engine.err`, `logs\frontend.err`.

> Son procesos normales: **se cierran al cerrar sesión / reiniciar Windows**.
> Para volver a levantarlos: `.\native\local.ps1 start`.

## Qué NO se sube (`.gitignore`)

- `Backend/` y `Frontend/` (código privado), `.env`, `deploy.config.ps1`, `logs/`.

## Mover a otro servidor

1. Instala los requisitos (Git, Node, Python, PostgreSQL).
2. `git clone` este repo (o copia la carpeta).
3. Copia tu `.env` y `deploy.config.ps1` (con el token y los puertos) al servidor.
4. Crea la BD en PostgreSQL (ver `GUIA_DESPLIEGUE.md` §3).
5. Doble clic en `instalar.bat`.

### Token para clonar sin login (recomendado en servidores)

En `deploy.config.ps1` pon un **GitHub PAT** (fine-grained, `Contents: Read-only`):
```powershell
$GitHubToken = "github_pat_xxx"
```
Se usa solo al clonar y no queda guardado en `.git/config`.
