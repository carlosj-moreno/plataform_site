# Auditoría de seguridad — 2026-08-12

**Alcance**: TODOS los endpoints del backend (≈120 vistas en `crm_views.py`,
`views.py`, `connection_views.py`, `gateway_views.py`, `agendamiento_views.py`),
revisados por aislamiento multi-tenant (empresa), permisos por sección (RBAC),
validación de escrituras y exposición de secretos. Tres auditores en paralelo +
verificación manual de cada hallazgo. **189 tests en verde tras los fixes.**

## Conclusión sobre el reporte que originó la auditoría

**No había fuga entre empresas** en "Mi Equipo" ni en "Configurar Bot": el
usuario `lider.gestores` veía los datos de Empresa Principal porque era admin
DE esa empresa. La corrección fue de diseño (separarlo en su propia empresa —
`separar_equipo_capturas.py`), no de seguridad. Sin embargo, la auditoría
completa sí encontró problemas reales, todos corregidos abajo.

## Corregido — severidad ALTA

1. **Validación de documentos enlazaba archivos de OTRA empresa**
   (`document_validation_service.py`): `document_id` del payload se buscaba sin
   filtro de tenant; luego las vistas de lectura firmaban la URL del archivo
   ajeno. Ahora el mensaje debe ser de la misma empresa del cliente.
2. **Campana de notificaciones con residuo cross-tenant** (`NotificationsView`):
   las revisiones asignadas/decididas no filtraban por empresa (fugaba nombre y
   teléfono si un usuario cambió de empresa). Ahora filtran igual que el resto.
3. **Pedir revisión sin gate** (`ReviewRequestListCreateView.POST`): cualquier
   rol (p. ej. gestor, con solo Pagos de Capturas) podía auto-asignarse una
   revisión de cualquier cliente y leer su ficha completa. Ahora exige una
   sección de casos (bandeja/operativo/super casos/salidas).
4. **Acciones masivas de Super Casos sin gate** (`SuperCaseMassActionView`,
   `SuperCaseCustomerView`): aprobación masiva de documentos y difusión de
   WhatsApp abiertas a cualquier autenticado del tenant. Ahora exigen la llave
   `super_cases` como el resto del módulo.
5. **Agendamiento sin noción de empresa**: el Agendador es UNA sola agenda; un
   usuario de otra empresa con la llave podía leer la agenda de los patios
   (nombres, documentos, placas) y cancelar citas por enumeración de ids.
   Ahora hay candado por empresa (`_empresa_con_agendador`).

## Corregido — gates de sección faltantes (solo `IsAuthenticated` antes)

- Interruptor del bot por cliente → llave `inbox`.
- Adjuntos del cliente, resumen IA del chat, veredicto IA de mensajes,
  documentos del cliente, datos del titular → llaves de casos
  (`inbox`/`dashboard`/`super_cases`/`salidas_convenios`).
- Etiqueta de caso → `inbox`/`dashboard`/`super_cases`.
- Tags (crear/borrar/asignar) → `inbox`/`dashboard`/`kanban`/`super_cases`.
- Movimientos financieros del cliente → `inbox`/`dashboard`/`carteras`.
- Insights IA de reportes (2 vistas) → `reports` (eran proxys LLM abiertos).
- Simulador de mensajes (`test-message`) → `inbox` o `connections`.

## Corregido — endpoints internos del engine

- Eliminada la **copia vieja y débil** de `InternalConnectionUpdateView` en
  `chat/views.py` (escribía `status` sin validar y borraba el QR en cada
  update); la ruta legacy apunta ahora a la implementación endurecida.
- **`WHATSAPP_ENGINE_ALLOWED_IPS=127.0.0.1`** activado en el `.env` del backend
  (la defensa por IP estaba apagada; ahora el secret + la IP local son
  obligatorios). Replicar en el `.env` del servidor al desplegar.

## Abierto — requiere decisión o trabajo posterior

- **`/media/` firmado no compara la empresa de la firma contra el dueño real
  del archivo** (la firma funciona como bearer sobre la ruta). Hoy no es
  explotable porque los emisores firman querysets ya aislados, pero es la red
  de seguridad que falta. Fix propuesto: resolver el dueño del path
  (Message/VehiclePhoto/Factura) y comparar. TTL 6h en query string.
- **"Aprobar Liquidaciones"** está hard-codeado a admin; la llave
  `liquidation_queue` del catálogo no gobierna la API (delegarla es decisión de
  negocio).
- **Revelar llave de aliado** devuelve el token en claro sin re-autenticación
  (mejorable con confirmación de contraseña).
- **Gateway `info/`** acepta `notes`/`datos_extra` sin cota de tamaño (un
  aliado podría inflar la BD; acotar longitudes).
- **Registro público** (`ALLOW_PUBLIC_REGISTRATION`) sigue cerrado — mantener.

## Pendiente operativo

- **Deploy al servidor** (producción): pull + `manage.py migrate` (0123/0124) +
  `WHATSAPP_ENGINE_ALLOWED_IPS` en su `.env` + reinicio de servicios.
- Local ya corre con todo aplicado (backend reiniciado, smoke tests OK:
  el engine entra, el gestor consulta pagos, y los endpoints ahora gateados
  le devuelven 403).
