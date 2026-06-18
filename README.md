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

El servidor se autentica a los repos privados con una **llave SSH (deploy key)**
de solo-lectura. El script pide la clave (passphrase de la llave) solo si no
está cargada en el agente SSH.

```bash
git clone git@github.com:carlosj-moreno/plataform_site.git
cd plataform_site

cp deploy.config.example.sh deploy.config.sh   # ya trae las URLs reales; ajusta la rama si hace falta
cp .env.docker.example .env                     # secretos reales

./deploy.sh        # clona/actualiza privados → docker compose up -d --build
```

> Los repos privados se clonan **dentro** de `Backend/bootwhatsapp/` y
> `Frontend/bootwhatsapp_frontend/` (no en la raíz de `Backend/`/`Frontend/`),
> porque la raíz de cada repo es directamente el proyecto Django / la app Vite.

Re-desplegar tras un cambio: `./deploy.sh` (vuelve a hacer pull + rebuild).

### Llave SSH (deploy key) en el servidor — una sola vez

```bash
ssh-keygen -t ed25519 -C "deploy@servidor" -f ~/.ssh/id_deploy
cat ~/.ssh/id_deploy.pub   # añadir como Deploy Key (read-only) en cada repo privado
```

Añade `~/.ssh/id_deploy.pub` como **Deploy Key (read-only)** en los dos repos
privados (`bootwhatsapp` y `bootwhatsapp_frontend`). Luego en `deploy.config.sh`
apunta `SSH_KEY="$HOME/.ssh/id_deploy"` (o cárgala con `ssh-add ~/.ssh/id_deploy`).

> Nota: una deploy key de GitHub sirve para **un** repo. Para dos repos, o usas
> dos llaves (una por repo) o marcas la misma como "machine user"/usas una llave
> de cuenta con acceso a ambos. Lo más simple: dos deploy keys y un bloque por
> host en `~/.ssh/config`.

Para la operación día a día (logs, migraciones, volúmenes, webhook de Meta)
ver [docker/README.md](docker/README.md).
