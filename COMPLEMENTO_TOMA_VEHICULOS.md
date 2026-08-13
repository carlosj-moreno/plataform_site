# COMPLEMENTO — SECCIÓN 2: TOMA E INGRESO DE VEHÍCULOS

**Documento base:** Especificación de Requerimientos: Automatización Logística V1.0 (Agosto 2026)
**Alcance de este complemento:** detalla la toma física del vehículo (registro fotográfico, formato de inventario, anclaje por placa) y agrega contingencias y reglas de calidad que la operación real ya demostró necesarias. Todo lo aquí descrito está validado en producción sobre ~200 fichas reales.

---

## 2.2 TOMA FÍSICA DEL VEHÍCULO — REGISTRO FOTOGRÁFICO OBLIGATORIO

Al momento de la toma (recepción física del vehículo en el patio), el operador captura y envía por WhatsApp el juego fotográfico del vehículo. El sistema debe archivar **12 ángulos fijos por momento** (un juego al INGRESO y otro juego a la SALIDA):

| # | Ángulo | Qué debe verse |
|---|--------|----------------|
| 1 | Delantera | Frente completo, parrilla y placa delantera, capó cerrado |
| 2 | Posterior | Parte trasera completa, stops y placa trasera |
| 3 | Lateral derecho | Perfil completo, sin placas visibles |
| 4 | Lateral izquierdo | Perfil completo, sin placas visibles |
| 5-7 | Interior 1 / 2 / 3 | Tablero, sillas, tapicería |
| 8 | Baúl | Compartimiento abierto |
| 9 | Repuesto | Llanta de repuesto |
| 10 | Kilometraje | Primer plano del odómetro |
| 11 | Llaves | Juego de llaves entregado |
| 12 | Motor | Capó abierto: bloque, batería, mangueras |

Además de las fotos, se admite **VIDEO** del vehículo (varios por momento), con el anuncio de ingreso o salida en el texto/caption.

### REGLA CRÍTICA (Carro en el suelo)
El inventario fotográfico es del carro **EN EL SUELO**. Las fotos del vehículo todavía **arriba de la grúa** (montado en la plataforma o colgando del gancho) **NO cuentan como inventario** y deben descartarse del archivo automático: el vehículo aún no está estacionado y ni las ruedas ni los bajos se ven como quedarán. (Estas fotos pueden conservarse como evidencia del traslado, pero no ocupan casillas del inventario.)

### REGLA CRÍTICA (La placa ancla la tanda)
El mismo chat/grupo de WhatsApp transporta **varios carros seguidos**. La regla operativa que evita mezclar fotos de carros distintos es: **el operador escribe la placa ANTES de cada ráfaga de fotos** (como texto o como caption de la primera foto). El sistema asigna cada foto a la placa anunciada más reciente. Reglas derivadas:

- Placa escrita (caption o texto reciente) es **autoritativa** y manda sobre cualquier inferencia.
- Sin placa escrita ni ráfaga en curso, el sistema puede leer la placa de la foto por visión, pero **nunca adivina**: sin ancla confiable, la foto queda pendiente de asignación manual.
- Foto reenviada (mismo contenido/hash) = duplicado, se descarta sin procesar.
- Ante conflicto entre la placa **tipeada** por el operador y la placa **visible en la foto**, la placa física en la foto es la evidencia más fuerte — verificar visualmente antes de fusionar o corregir fichas.

---

## 2.3 FORMATO FÍSICO DE INVENTARIO (PLANILLA DEL PATIO)

Junto con las fotos llega el formato "INVENTARIO DE VEHÍCULO" (PDF o foto): página 1 = planilla manuscrita; páginas 2-3 = **licencia de tránsito** impresa (ambas caras), cuando el patio la anexa.

Reglas de extracción validadas en producción:

1. **Lo impreso pisa lo manuscrito.** Si la licencia de tránsito coincide en placa con la planilla, sus datos impresos (marca, línea, clase, color, modelo, motor, chasis/VIN, propietario, identificación) prevalecen sobre la transcripción del manuscrito.
2. **VIN/chasis con formato duro.** VIN = 17 alfanuméricos, **nunca contiene I, O ni Q**. Todo VIN que no valide se marca para revisión humana; no se corrige por posición (los VIN suramericanos/asiáticos no siguen la convención norteamericana).
3. **"No. DE SERIE" y "No. CHASIS" son dos renglones distintos** de la planilla; en la práctica el VIN se escribe en uno y el otro queda en blanco. No tratarlos como sinónimos a ciegas: mismo valor en ambos = un solo dato; valores distintos = decide el operador.
4. **Confusiones de caracteres reales del manuscrito** (medidas en auditoría de 196 fichas): I/T, V/U, 5/S, Q/O, B/8, B/6, B/E. Cualquier lectura de placa o serial debe resolverse por **mayoría entre lecturas independientes** (varios encuadres y/o modelos), nunca por una lectura única — una relectura suelta acierta o alucina con la misma confianza.
5. **Nunca inventar.** Campo ilegible o en blanco queda vacío y marcado para el operador; los datos legales (juzgado, demandante, demandado) jamás se sobreescriben sin acuerdo unánime entre lecturas.
6. **Kilometraje, llaves y tarjeta** se leen del formato; si el kilometraje no figura (hallazgo recurrente: viene en blanco en el papel — es un fix operativo, no de software), se registra igualmente el estado de llaves y tarjeta, como ya indica la sección 2 del documento base.

---

## 2.4 OBSERVACIÓN LEGAL SOBRE EL RUNT (corrección al flujo de la sección 2)

El documento base indica "Consulta y Extracción RUNT" automática. **Precaución:** los términos del portal del RUNT **prohíben la consulta automatizada** (captcha + condiciones de uso). Un bot que resuelva o eluda el captcha incumple los T&C y es frágil ante cualquier cambio del portal.

Alternativas viables, en orden de preferencia:

1. **Proveedor autorizado con API** (servicio pago): única vía 100 % automática y legalmente limpia. Presupuestarla si el volumen lo justifica.
2. **Consulta manual asistida** (lo implementado hoy): el sistema pre-diligencia placa y cédula del propietario en el formulario del portal; al operador solo le queda resolver el captcha y pulsar Consultar. El resultado (PDF/pantallazo) se sube al expediente y el sistema extrae de él número de inventario, fecha de registro y demás campos.

Nota adicional para la Contingencia A (búsqueda por chasis): el portal exige la cédula del **PROPIETARIO** registrado, no la del demandado — por eso falla la consulta cuando el demandado no es el propietario. El dato de propietario/cédula debe capturarse del formato de inventario o de la licencia de tránsito para tenerlo disponible antes de la consulta.

---

## 2.5 CONTINGENCIAS ADICIONALES (TOMA)

**CONTINGENCIA C — El archivo no descarga.** Los adjuntos de WhatsApp fallan en la descarga con frecuencia (media expirado, red). El sistema debe reintentar la descarga (≥3 intentos) y, si aun así falla, **avisar en el chat pidiendo el reenvío** — nunca dejar un registro mudo sin archivo, porque el formato "se pierde" en silencio.

**CONTINGENCIA D — Las fotos llegan antes que el anuncio.** Es normal que la ráfaga de fotos llegue **antes** del texto de ingreso. Al llegar el anuncio (que trae la placa), el sistema debe recoger retroactivamente las fotos sueltas de los últimos ~30 minutos del mismo chat y adjuntarlas a la ficha recién anclada.

**CONTINGENCIA E — Ficha fantasma por placa mal leída.** Dos lecturas de la misma placa que difieren en un carácter (ej. KQM195 / KOM195) crean fichas duplicadas. Regla: al crear ficha nueva, si existe una ficha reciente (<7 días) cuya placa difiere en **un solo carácter**, se reutiliza esa ficha en lugar de crear otra.

**CONTINGENCIA F — Error humano en el caption.** El operador puede tipear la placa de otro carro en el caption. Ante inconsistencia (la placa visible en la foto no coincide con la tipeada), no fusionar ni borrar automáticamente: escalar a verificación visual humana.

---

## 4-BIS. FILAS ADICIONALES PARA LA MATRIZ DE ORIGEN DE DATOS

| Variable / Campo | Fuente Principal | Regla Técnica / Contingencia |
|---|---|---|
| Juego fotográfico (12 ángulos × ingreso/salida) | WhatsApp (fotos de la toma) | Solo carro EN EL SUELO; la placa escrita antes de la ráfaga ancla la tanda; duplicados por hash se descartan. |
| Video de ingreso/salida | WhatsApp | Momento según el anuncio del caption ("INGRESA VEHÍCULO…" / "SALE VEHÍCULO DE PLACAS… – PERSONA AUTORIZADA … CC …"). |
| Placa (ancla de la ficha) | Formato de inventario + fotos | Lecturas múltiples y mayoría cualificada; confusiones I/T, V/U, 5/S, Q/O, B/8; conflicto tipeado-vs-foto → revisión humana. |
| VIN / No. Chasis / No. Serie | Formato + licencia de tránsito | 17 caracteres sin I/O/Q; serie y chasis son renglones distintos; sin acuerdo entre lecturas → marcar "revisar", no corregir. |
| Marca, línea, clase, color, modelo | Licencia de tránsito (impresa) | Lo impreso pisa lo manuscrito si la placa coincide. |
| Propietario y cédula del propietario | Formato / licencia de tránsito | Necesarios ANTES de la consulta RUNT (el portal los exige junto a la placa). |
| Resultado RUNT | Portal RUNT (consulta asistida) o API de proveedor autorizado | El portal prohíbe automatización (captcha + T&C); pre-diligenciar y dejar captcha+clic al operador; archivar PDF/pantallazo como evidencia. |
| Observaciones de estado (golpes, rayones) | Formato de inventario | Transcripción FIEL al papel; solo correcciones ortográficas inequívocas; nunca reinterpretar (dato con valor legal). |
