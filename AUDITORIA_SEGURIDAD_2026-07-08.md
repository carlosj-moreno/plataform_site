# Auditoría de Seguridad — BootWhatsapp

**Fecha:** 2026-07-08
**Alcance:** Backend Django/DRF (`Backend/bootwhatsapp`), despliegue nativo Windows (`native/`, `deploy.ps1`), configuración y secretos.
**Método:** 5 revisiones paralelas por dimensión (auth/RBAC/multi-tenant · gateway/webhook/HMAC · SSRF/media/lookups · secretos/cripto/despliegue · inyección/fugas del bot LLM), sobre el **código actual** (incluye los cambios sin commitear del endurecimiento de despliegue nativo). Los hallazgos MEDIO clave se verificaron leyendo el código real.

---

## Resumen ejecutivo

La base es **madura y está bien endurecida**. Ha pasado por rondas previas de auditoría (2026-07-03/06) y la mayoría de los vectores clásicos están cerrados con mitigaciones correctas y documentadas en el propio código.

> **Estado de remediación (2026-07-08):** los **11 defectos de código** detectados (4 medios + 7 bajos) fueron **corregidos, compilados y probados** en esta ronda — 105 tests OK, Django check limpio, migración de blacklist JWT aplicada. El único riesgo que queda abierto es **operativo** (C1: rotar secretos + ACL del `.env`), que depende de acción del operador en los proveedores y en el servidor, no del código.

- **Cero vulnerabilidades CRÍTICAS o ALTAS de código** explotables por un atacante externo.
- El único riesgo **CRÍTICO es operativo**: secretos reales de producción en texto plano en `.env` en disco (no en git). Continuación del hallazgo previo.
- Los defectos de código eran de severidad **MEDIA/BAJA** (fugas de RBAC de sección, ruta de fallback cross-tenant, endurecimientos de defensa en profundidad) y **ya están resueltos**.
- **git está limpio** en el historial completo de ambos repos: nunca se commiteó un `.env` real, `data_backup.json` ni `deploy.config.ps1`.

### Tabla de hallazgos

| # | Severidad | Área | Título | Estado |
|---|-----------|------|--------|--------|
| C1 | **CRÍTICO** (operativo) | Secretos | Secretos reales de prod en `.env` en disco; tokens de terceros sin rotar | ⚠ Acción operador |
| M1 | MEDIO | Multi-tenant | `get_active_connection()` sin filtro de empresa → ruteo de salida cross-tenant en fallback | ✔ Corregido |
| M2 | MEDIO | RBAC | 4 endpoints de Reportes/Super-Casos con `IsAuthenticated` en vez de `section_perm` | ✔ Corregido |
| M3 | MEDIO | Config/TLS | `--forwarded-proto https` + bind `0.0.0.0` sin TLS real en LAN | ✔ Corregido |
| M4 | MEDIO | Red | Whitelist de IP del engine es opt-in y queda inerte por defecto | ✔ Corregido |
| B1 | BAJO | Config | JWT sin rotación/revocación de refresh tokens (no blacklist) | ✔ Corregido |
| B2 | BAJO | DoS | `download_meta_media` sin `stream`/tope de bytes | ✔ Corregido |
| B3 | BAJO | SSRF | `download_url` de Meta sin allowlist de host | ✔ Corregido |
| B5 | BAJO | Despliegue | PAT embebido en URL de `git` (visible en args de proceso) | ✔ Corregido |
| B6 | BAJO | DoS | `serve.py` lee el body proxeado completo sin tope | ✔ Corregido |
| B7 | BAJO | LLM | Turno de usuario en vivo sin re-sanitizar; regex de secretos con huecos | ✔ Corregido |
| B4 | Info | Rate-limit | Rate-limit del gateway por-worker (LocMem): requiere cache compartido | ⚠ Acción infra |
| B8 | Info | Auth | Auto-registro público crea admin+empresa sin verificación | Decisión de negocio |

> **Nota.** Los detalles de cada fix aplicado están consolidados en el PDF (`AUDITORIA_SEGURIDAD_2026-07-08.pdf`, sección «Correcciones aplicadas»). Las secciones siguientes describen los hallazgos tal como se detectaron originalmente.

---

## Hallazgos detallados

### C1 · CRÍTICO (operativo) — Secretos reales de producción en `.env` en disco

**Archivo:** `C:\BootWhatsapp\.env` (fuera de git). `deploy.ps1` además lo **copia** a `Backend\bootwhatsapp\.env`, duplicando la exposición.

Contiene en texto plano y vigentes: `SECRET_KEY`, `JWT_SIGNING_KEY`, `DB_PASSWORD`, `FERNET_KEY`, `INTEGRATION_SALT`, `WHATSAPP_ENGINE_SECRET`, y credenciales de terceros `WHATSAPP_API_TOKEN` (token Meta), `WHATSAPP_APP_SECRET`, `META_VERIFY_TOKEN`, `GROQ_API_KEY`, `TOGETHER_API_KEY`.

**Escenario:** cualquiera con lectura del filesystem (malware, backup no cifrado, RDP comprometido, robo del equipo) obtiene: el token de Meta (suplanta la línea WhatsApp), la clave Fernet (descifra todos los `access_token` de la BD), y la firma JWT (forja sesiones de cualquier usuario/empresa).

**Acción:**
1. **Rotar en proveedor** los tokens de terceros expuestos: Meta (`WHATSAPP_API_TOKEN` + `WHATSAPP_APP_SECRET`), `GROQ_API_KEY`, `TOGETHER_API_KEY`. (Las claves internas Django/DB/Fernet/JWT ya se rotaron el 2026-07-03; los tokens de terceros no consta.)
2. Restringir ACL del `.env` al usuario del servicio: `icacls .env /inheritance:r /grant:r "<usuario-servicio>:R"`.
3. Excluir/cifrar `.env` en los backups del equipo.
4. Cifrar/borrar `data_backup.json` si existe (dumpdata serializa `access_token` **descifrado**).
5. Al rotar `FERNET_KEY` en el futuro: `FERNET_KEY=NUEVA,VIEJA` → `python manage.py reencrypt_fernet --apply` → dejar solo `NUEVA`. **Nunca** regenerar la Fernet sin reencriptar antes (rompe tokens en silencio → Meta 401).

---

### M1 · MEDIO — Ruteo de salida cross-tenant en el fallback de conexión

**Archivos:** `chat/services/connection_manager.py:63` (`get_active_connection()` no recibe `company`) · `chat/services/message_handler.py:1451-1481` (`_get_sticky_or_active` → `get_active_connection()`).

`get_active_connection()` selecciona la mejor conexión activa **de toda la instalación, sin filtrar por empresa**. `_get_sticky_or_active(conversation)` tiene disponible `conversation.customer.company` pero no lo pasa.

**Escenario:** un mensaje entrante que no resuelve `phone_number_id` ni trae `connection_id` y cuya conversación no tiene conexión sticky válida (canal QR/legacy, o una llamada a `handle_incoming_message` sin conexión) puede responder al cliente **por la línea WhatsApp de otro tenant**. El contenido pasa por el guard (no filtra secretos), pero se rompe el aislamiento y se revela al cliente la identidad/línea de otra empresa. La vía crítica del webhook Meta ya está endurecida (descarta si no matchea); este es el residual del fallback.

**Fix:** pasar la empresa — `get_active_connection(company=conversation.customer.company)` — filtrar el queryset por ella, y si `company is None` descartar en lugar de elegir global (espejo de la lógica del webhook).

---

### M2 · MEDIO — Bypass de RBAC de sección en 4 endpoints de Reportes/Super-Casos

**Archivo:** `chat/crm_views.py`
- `SuperCaseReportView` → `permission_classes = [IsAuthenticated]` (línea 8659)
- `SuperCaseReportExportView` → `IsAuthenticated` (línea 8716)
- `NaturalLanguageReportView` (`POST /crm/reports/query/`) → `IsAuthenticated` (línea 9106)
- `QueryDataView` (`POST /crm/query-data/`) → `IsAuthenticated` (línea 9151)

Sus vistas hermanas usan `section_perm('reports')` / `section_perm('super_cases')`. Estas cuatro quedaron sin gate de sección.

**Escenario:** un `validador`, `salidas_manager`, `inventario_vehicular`, o un `agent` al que el admin **quitó** explícitamente la sección (o una empresa cuyo `enabled_tools` no la incluye) puede llamar estos endpoints con su JWT y obtener reportes agregados / consolidado del Super-Caso que la UI le oculta. **No es cross-tenant** (los datos siguen escopados a su empresa) — es escalada de *sección* dentro del tenant.

**Fix:** `permission_classes = [section_perm('reports')]` en `NaturalLanguageReportView` y `QueryDataView`; `[section_perm('super_cases')]` en `SuperCaseReportView` y `SuperCaseReportExportView`.

---

### M3 · MEDIO — Inconsistencia TLS: proxy anunciado como HTTPS pero sirviendo HTTP en LAN

**Archivos:** `native/local.ps1:86` (`--forwarded-proto https` incondicional) · `.env:27` (`ENABLE_HTTPS=True`) · `core/settings.py:363-369`.

`serve.py` escucha en `0.0.0.0:8080` sirviendo **HTTP plano en la LAN**, pero se anuncia al backend como `https`. Django entonces emite cookies con flag `Secure` y `Strict-Transport-Security` incluso sobre HTTP.

**Escenario:** si un cliente accede por `http://<IP-LAN>:8080` (no por el túnel devtunnels que sí termina TLS), o bien la sesión/CSRF se rompe (el navegador no reenvía cookies `Secure` sobre HTTP), o se fijan cookies `Secure` sobre tráfico que viajó en claro por la LAN. La coherencia depende de que nadie use la IP LAN directa.

**Fix:** bindear el proxy a `127.0.0.1` y exponer solo el túnel TLS; **o** poner un terminador TLS real (Caddy/nginx) delante; **o** bloquear por firewall el `:8080` LAN. Evitar el desalineamiento `--forwarded-proto https` hardcodeado vs `ENABLE_HTTPS`.

---

### M4 · MEDIO — Whitelist de IP del engine es opt-in y queda inerte por defecto

**Archivos:** `chat/views.py:366-372` · `chat/connection_views.py:386-391` · `core/settings.py` (sin default para `WHATSAPP_ENGINE_ALLOWED_IPS`).

La whitelist solo se aplica `if allowed_ips:`. Sin configurarla, la única defensa de los endpoints internos (`AllowAny`, sin throttle) es el `WHATSAPP_ENGINE_SECRET`.

**Escenario:** con el secret filtrado (ver C1) y sin whitelist, un atacante hace `POST /api/internal/connection-update/` con `type:"message"` y un `connection_id` arbitrario para **inyectar mensajes entrantes falsos en cualquier tenant** (dispara el bot/LLM del dueño de esa línea) y quemar créditos del LLM sin límite.

**Fix:** hacer `WHATSAPP_ENGINE_ALLOWED_IPS` efectivamente requerido en producción (warning/fail si vacío) y/o añadir rate-limit por-connection a estos endpoints.

---

### Hallazgos BAJO

- **B1 — JWT sin blacklist** (`core/settings.py:158-168`): `ACCESS 1h / REFRESH 7d` sin `ROTATE_REFRESH_TOKENS`/`BLACKLIST_AFTER_ROTATION`/`token_blacklist`. Un refresh filtrado o un usuario desactivado no se puede revocar hasta 7 días. **Fix:** habilitar `token_blacklist` + rotación.
- **B2 — `download_meta_media` sin tope** (`chat/services/whatsapp_api.py:65-67`): `requests.get(...).content` carga todo en memoria sin `stream=True` ni límite → DoS por RAM. **Fix:** `stream=True` + `iter_content` abortando al superar ~20 MB.
- **B3 — `download_url` de Meta sin allowlist** (`chat/services/whatsapp_api.py:61-65`): el segundo GET no valida que el host sea `*.fbcdn.net`/`facebook.com`; el token de Meta viaja a la URL que Graph indique. SSRF teórico. **Fix:** allowlist de sufijo de host antes del GET.
- **B4 — Rate-limit del gateway por-worker y fail-open** (`chat/services/integration_gateway.py:118-136`): cache LocMem → límite efectivo `N×` por N workers; `except: return False`. Permite scraping de existencia de teléfonos vía `/gateway/verify/` por encima de la tasa nominal. **Fix:** cache `default` a Redis/Memcached compartido.
- **B5 — PAT en URL de git** (`deploy.ps1:60-65,118-125`): `https://x-access-token:$token@github.com/...` como argumento de `git` es visible a otros procesos del mismo usuario. Mitigado (se limpia el remote tras clonar) pero el `fetch` de actualización lo reusa. **Fix:** credential helper / `http.extraHeader` vía stdin.
- **B6 — `serve.py` body sin tope** (`native/serve.py:50-51`): `self.rfile.read(length)` completo en memoria. Mitigado por throttle DRF + túnel. **Fix:** tope de tamaño.
- **B7 — Endurecimientos LLM**: el turno de usuario en vivo se anexa crudo al prompt (`chat/services/ai_service.py:784-785`) — la defensa recae en el sandwich anti-leak; y `_LEAK_PATTERNS` (`ai_service.py:257-278`) puede no capturar un valor Fernet crudo sin su etiqueta. Riesgo real bajo (el system prompt no contiene secretos). **Fix opcional:** sanitizar Unicode del turno vivo + patrón para blobs Fernet/base64 de alta entropía.
- **B8 — Auto-registro público** (`chat/crm_views.py:61`, `RegisterView` público): crea `User`+`Company`+admin sin verificación de email. No es escalada intra-tenant (cada registrante es admin de su propia empresa nueva); riesgo de abuso/spam. **Fix (si aplica):** desactivar auto-registro o añadir verificación/invitación/CAPTCHA.

---

## Controles verificados que están BIEN implementados

**Auth / multi-tenant**
- Aislamiento multi-tenant consistente: `get_object_or_404(..., company=_get_company(user))` en todos los accesos por pk; `_get_company` es **fail-closed** (403, no degrada a `company=None`). El bug histórico de `CustomerDetailView` sigue corregido.
- IDOR protegido (p. ej. `ReviewRequestDecideView`: empresa **y** propiedad `assigned_to_id`).
- Anti-escalada en "Mi Equipo": un no-admin no crea/edita/asciende admins, no se auto-modifica, roles validados contra whitelist, `secondary_role` nunca `admin`/`aliado`.
- Override de permisos **autoritativo** (`complete_permissions_input`): las claves ausentes se guardan `False`, cerrando el default generoso del rol agente; `_mask_with_company_tools` respeta `enabled_tools`.

**Gateway / webhook / HMAC**
- Firma HMAC del webhook: **fail-closed** (sin secret/sin header → rechaza) + `hmac.compare_digest` sobre el body crudo. `verify_token` con `bool(...)` + constant-time.
- Fallback cross-tenant del webhook **sigue eliminado** (descarta el mensaje si `phone_number_id` no matchea).
- Gateway: hash `sha256(token+salt)` con salt fail-closed, comparación constant-time, scopes por endpoint, tenant fail-closed (`_tenant_scoped` → `qs.none()` si `company_id` es None).
- Engine secret constant-time; `_trusted_client_ip` **resistente a spoofing de X-Forwarded-For** (usa `REMOTE_ADDR`, no el primer XFF).
- `/reveal/` de aliado: por diseño, gateado por sección `aliados` + misma empresa; el hash de auth real es irreversible (sha256+salt).

**SSRF / media / PDF**
- `external_lookup`: allowlist por `ip.is_global` (bloquea privadas/loopback/link-local/**169.254.169.254**/CGNAT/ULA), **anti DNS-rebinding** real (`_PinnedIPAdapter`), resuelve todas las IPs, **no sigue redirects** auto y **quita el header de auth al cambiar de host**, HTTPS obligatorio en prod, tope de respuesta 1 MB, todo auditado.
- Media firmada (`TimestampSigner`, path+company, TTL 6h) + anti path-traversal (`startswith(media_root+sep)`) + `as_attachment` salvo tipos inline seguros + `nosniff` → XSS almacenado neutralizado.
- Subida: extensión derivada del **MIME validado**, `_UNSAFE_EXTS` forzadas a extensión segura, `basename` anti-traversal.
- PDF (`pdf_report`): **todo** texto no confiable (OCR/IA/manual) pasa por `_esc()` antes de `Paragraph` → sin inyección de markup reportlab.
- DIAN: la URL del QR se trata solo como texto (no hay fetch) → sin SSRF.

**Secretos / cripto / despliegue**
- `SECRET_KEY` sin default (aborta si falta); `JWT_SIGNING_KEY` dedicada; `DEBUG=False` por defecto y desacoplado del hardening HTTPS; `ALLOWED_HOSTS` sin comodín (subdominio exacto del túnel); CORS/CSRF fail-closed y explícitos; `DB_PASSWORD` rotada a valor fuerte.
- Fernet: `MultiFernet` con rotación por lista; `from_db_value` distingue legacy vs corrupto y devuelve `None`+log (fail-safe, no fail-open); `reencrypt_fernet` idempotente/transaccional que salta filas ilegibles.
- waitress bindea a `127.0.0.1` (no expuesto directo); `serve.py` con anti-traversal y headers de seguridad en estáticos.
- **git limpio** en historial completo de ambos repos; `.gitignore` cubre `.env*`, `data_backup.json`, `deploy.config.ps1`, `media/`, `*.key`, `*.pem`. Sin secretos hardcodeados en código.

**Bot / LLM**
- **Portero doble**: `guard_outbound` en cada call site **y** dentro de `send_with_fallback` (embudo final) → todo texto saliente se filtra aunque un call site futuro lo olvide.
- Contexto del LLM inyecta **solo el nombre** del cliente (envuelto como dato no confiable); sin notas internas, `datos_extra`, ni liquidaciones. Historial excluye `internal=True`.
- Centinela `_confidencial` en `calcular_liquidacion` + `assert_not_confidential`: el dict de liquidación no puede convertirse en respuesta.
- Whitelist de eco `_ECHO_SAFE_DATA_KEYS` (solo placa/cédula al cliente).
- Sanitización Unicode completa (NFKC + Cf/Cc) + sandwich anti-leak; visión/OCR envuelto como dato no confiable con validación de esquema.
- **Sin** SQL crudo (`.raw`/`.extra`/`cursor.execute`), **sin** `eval`/`exec`/`os.system`/`subprocess`/`pickle`/`yaml.load` con datos de usuario. Todo ORM.
- Suite de 105 tests con 5 archivos anti-fugas que congelan los invariantes.

---

## Plan de remediación priorizado

1. **C1 (CRÍTICO operativo):** rotar tokens de terceros (Meta/Groq/Together) + ACL sobre `.env` + revisar backups. Es lo único con impacto real inmediato.
2. **M2 (MEDIO, esfuerzo mínimo):** añadir `section_perm(...)` a los 4 endpoints — 4 líneas.
3. **M1 (MEDIO):** filtrar `get_active_connection` por empresa en el fallback.
4. **M3 / M4 (MEDIO):** resolver la incoherencia TLS del proxy y hacer obligatoria la whitelist de IP del engine en producción.
5. **B1–B8 (BAJO):** endurecimientos de defensa en profundidad según capacidad.

Ninguno de los defectos de código es explotable como crítico/alto por un atacante externo. La prioridad es operativa (secretos) y luego cerrar los cuatro huecos MEDIO.
