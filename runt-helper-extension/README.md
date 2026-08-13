# Consultas asistidas RUNT + DIAN + TYBA (extensión de Chrome)

Extensión interna de La Principal para que las consultas en portales del
Estado desde el CRM sean **solo captcha + botón**. Cubre tres portales:

## TYBA — Consulta de Procesos Judiciales (Rama Judicial, oficios)

En TYBA (`procesojudicial.ramajudicial.gov.co` — Justicia XXI) hay que digitar
el **departamento** y el **código del proceso**. Con la extensión instalada:

1. En la ficha del vehículo, clic en **"Abrir TYBA (oficios)"** (tarjeta
   Proceso judicial).
2. El portal se abre con el **código del proceso ya escrito** (viaja en el
   enlace) y el **departamento ya elegido** — la extensión lo deduce de los
   2 primeros dígitos de la radicación (código DANE del departamento).
3. El operador presiona **Consultar**, toma el pantallazo del resultado y lo
   sube en la misma tarjeta con **"Pegar pantallazo"**.

Sin la extensión, nada se rompe: el CRM copia el número de proceso al
portapapeles al abrir el enlace — se pega a mano y el departamento se elige
manualmente.

## Catálogo de facturas de la DIAN (verificación del CUFE)

Desde jul-2026 el formulario de la DIAN exige, junto al CUFE, el **NIT del
Emisor o Receptor** — y su servidor no permite pre-diligenciarlo por URL.
Con la extensión instalada:

1. En el CRM, clic en **"verificar en la DIAN →"** junto al CUFE de la factura.
2. La página abre con el **CUFE ya diligenciado** (eso lo hace la propia DIAN)
   y la extensión escribe el **NIT** (viaja en el `#nit=` del enlace, que nunca
   llega al servidor de la DIAN).
3. El operador solo resuelve el captcha y presiona **Buscar**.

Sin la extensión, nada se rompe: el CRM copia el NIT al portapapeles al abrir
el enlace y lo muestra en un chip junto al CUFE — se pega a mano.

## Consulta ciudadana del RUNT

Extensión para que la consulta del RUNT desde la ficha
del vehículo sea **solo captcha + Consultar**:

1. En el CRM, el operador abre la ficha del vehículo y hace clic en
   **"Abrir portal del RUNT"** (sección Consulta RUNT).
2. El portal se abre con la **placa** y la **cédula del propietario** ya
   escritas (viajan en el enlace; la cédula sale de la licencia de tránsito que
   la IA ya leyó en la ficha). Si la ficha aún no tiene la cédula, la extensión
   rellena el último documento consultado en ese equipo como respaldo.
3. El operador solo resuelve el **captcha** y presiona **Consultar**.
4. Descarga el PDF (o toma el pantallazo) y lo sube en la misma ficha con
   **"Subir PDF / pantallazo"**: la ficha se llena sola con los datos extraídos.

El captcha NO se toca: es la verificación humana que el RUNT exige y la razón
por la que la consulta no puede ser 100 % automática.

## Instalación (una vez por equipo)

1. Copiar esta carpeta (`runt-helper-extension`) al equipo del operador,
   por ejemplo a `C:\runt-helper-extension`. **No borrarla después**: Chrome
   la lee desde ahí.
2. Abrir Chrome (o Edge) y entrar a `chrome://extensions`
   (en Edge: `edge://extensions`).
3. Activar el **Modo de desarrollador** (interruptor arriba a la derecha).
4. Clic en **"Cargar descomprimida"** y elegir la carpeta copiada.
5. Listo. La primera vez el operador escribe su tipo y número de documento en
   el portal; desde la siguiente consulta ya aparecen escritos.

## Notas

- Solo actúa en `runt.gov.co`, en `catalogo-vpfe.dian.gov.co/User/SearchDocument`
  y en `procesojudicial.ramajudicial.gov.co`; no lee ni toca ninguna otra página.
- Si ya estaba instalada una versión anterior: reemplazar la carpeta por esta y
  en `chrome://extensions` presionar **Actualizar** (⟳) para que tome los
  portales nuevos (v1.3.0 suma TYBA).
- El documento del operador se guarda únicamente en ese equipo
  (`chrome.storage.local`), nunca viaja al CRM ni a terceros.
- Si el RUNT rediseña su formulario y la placa deja de aparecer sola, la
  extensión no rompe nada: el operador puede seguir pegando la placa (el CRM
  también la copia al portapapeles al abrir el portal).
