# plataform_site — Configuración de Docker / Despliegue

Este repositorio aloja **solo la configuración de Docker y despliegue** de la
plataforma. **No contiene el código de la aplicación** (Backend Django y
Frontend React), que vive en sus propios **repositorios privados**.

```
plataform_site/
├── docker-compose.yml        # orquestación de los 3 servicios
├── docker/                   # Dockerfiles + nginx + entrypoint
│   ├── backend/  engine/  frontend/
│   └── README.md             # operación detallada del stack
├── .env.docker.example       # plantilla de variables (sin secretos)
├── deploy.config.example.sh  # plantilla: URLs de los repos privados
└── deploy.sh                 # despliegue en el servidor (clona privados + compose)
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

cp deploy.config.example.sh deploy.config.sh   # URLs reales de Backend/Frontend
cp .env.docker.example .env                     # secretos reales

./deploy.sh        # clona/actualiza privados → docker compose up -d --build
```

Re-desplegar tras un cambio: `./deploy.sh` (vuelve a hacer pull + rebuild).

### Llave SSH (deploy key) en el servidor — una sola vez

```bash
ssh-keygen -t ed25519 -C "deploy@servidor" -f ~/.ssh/id_deploy
cat ~/.ssh/id_deploy.pub   # añadir como Deploy Key (read-only) en cada repo privado
```

Luego en `deploy.config.sh` apunta `SSH_KEY="$HOME/.ssh/id_deploy"` (o cárgala
en el agente con `ssh-add ~/.ssh/id_deploy`).

> Estructura esperada de los repos privados: el de **Backend** debe contener
> `bootwhatsapp/` en su raíz, y el de **Frontend** `bootwhatsapp_frontend/`,
> porque así los referencian los Dockerfiles.

Para la operación día a día (logs, migraciones, volúmenes, webhook de Meta)
ver [docker/README.md](docker/README.md).
