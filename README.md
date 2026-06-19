# plataform_site — Configuración de Docker / Despliegue

Este repositorio aloja **solo la configuración de Docker y despliegue** de la
plataforma. **No contiene el código de la aplicación**, que vive en sus propios
**repositorios privados**:

- Backend Django → `github.com/carlosj-moreno/bootwhatsapp` → se clona en `Backend/bootwhatsapp/`
- Frontend React + engine → `github.com/carlosj-moreno/bootwhatsapp_frontend` → se clona en `Frontend/bootwhatsapp_frontend/`

```
plataform_site/
├── docker-compose.yml        # orquestación de los 3 servicios
├── docker/                   # Dockerfiles + nginx + entrypoint
│   ├── backend/  engine/  frontend/
│   └── README.md             # operación detallada del stack
├── .env.docker.example       # plantilla de variables (sin secretos)
├── deploy.config.example.*   # plantilla: URLs de los repos privados (.sh y .ps1)
├── deploy.sh                 # despliegue en servidor Linux (clona privados + compose)
└── deploy.ps1                # despliegue en servidor Windows (Docker Desktop)
```

## Qué NO se sube (ya cubierto por `.gitignore`)

- `Backend/` y `Frontend/` → código privado, se clona en el servidor.
- `.env`, `*.key`, `*.pem`, `secrets.*` → secretos reales.
- Sesiones de WhatsApp (`.wwebjs_auth/`), media de clientes, prompts de negocio.
- `deploy.config.sh` → URLs/ramas reales (el `.example` sí se versiona).

## Despliegue en el servidor

Por defecto los repos privados se clonan por **HTTPS**: git pide las credenciales
de GitHub la **primera vez** y las cachea (en Windows, Git Credential Manager abre
el navegador; en Linux, un token/PAT). Como los repos son de la misma cuenta, hay
acceso completo. No requiere llaves SSH.

**Windows (Docker Desktop):**
```powershell
git clone https://github.com/carlosj-moreno/plataform_site.git
cd plataform_site

Copy-Item deploy.config.example.ps1 deploy.config.ps1   # URLs reales (HTTPS); ajusta rama si hace falta
Copy-Item .env.docker.example .env                       # secretos reales

.\deploy.ps1        # clona/actualiza privados → docker compose up -d --build
```

**Linux:**
```bash
git clone https://github.com/carlosj-moreno/plataform_site.git
cd plataform_site
cp deploy.config.example.sh deploy.config.sh
cp .env.docker.example .env
./deploy.sh
```

> Los repos privados se clonan **dentro** de `Backend/bootwhatsapp/` y
> `Frontend/bootwhatsapp_frontend/` (no en la raíz de `Backend/`/`Frontend/`),
> porque la raíz de cada repo es directamente el proyecto Django / la app Vite.

Re-desplegar tras un cambio: `.\deploy.ps1` / `./deploy.sh` (pull + rebuild).

### Portátil entre máquinas/servidores: token en la config (recomendado)

Para que cada máquina nueva clone **sola** (sin login en el navegador), pon un
**GitHub Personal Access Token** (fine-grained, `Contents: Read-only` sobre los 2
repos) en `deploy.config.ps1` / `deploy.config.sh`:

```powershell
$GitHubToken = "github_pat_xxx"   # Windows (deploy.config.ps1)
```
```bash
GITHUB_TOKEN="github_pat_xxx"     # Linux (deploy.config.sh)
```

El script inyecta el token solo al clonar/actualizar y **no lo deja guardado** en
`.git/config`. Como `deploy.config.*` está en `.gitignore`, el token no se sube.

**Provisionar una máquina nueva** entonces es:
```
git clone https://github.com/carlosj-moreno/plataform_site.git
# copiar deploy.config.(ps1|sh) + .env a esta máquina
.\deploy.ps1   # o ./deploy.sh   → clona todo sin pedir nada
```

### Otras alternativas

- **Sin token** — git pide login la primera vez (Credential Manager abre el
  navegador en Windows) y lo cachea. Cómodo en una sola máquina con escritorio.
- **Llave SSH (deploy key)** — cambia las URLs de `deploy.config.*` a
  `git@github.com:...`. Una deploy key sirve para **un** repo; para dos, usa dos
  llaves con bloques por host en `~/.ssh/config`, o una llave de cuenta con acceso
  a ambos.

Para la operación día a día (logs, migraciones, volúmenes, webhook de Meta)
ver [docker/README.md](docker/README.md).
