# -*- coding: utf-8 -*-
r"""Exporta a C:\FotosVehiculos\temporal UNA foto por posicion de TODAS las
fichas con fotos (historico completo) + la foto del formato de inventario.
Pedido del dueno 2026-07-30: "siempre" es siempre — sin ventana de tiempo,
ninguna foto se queda sin exportar aunque el servidor pase dias apagado.

Reglas pedidas por el dueno (2026-07-30):
  - UNA sola foto por posicion (ingreso manda; salida solo si esa posicion
    no tiene foto de ingreso). Nunca dos de la misma posicion.
  - Nombres LIMPIOS, sin numeros largos ni sufijos aleatorios:
      {PLACA}_inventario_{posicion}_{momento}.{ext}
      {PLACA}_formato.{ext}
  - Si el destino ya existe se REEMPLAZA (idempotente: correr N veces no
    duplica nada).

Corre solo, cada 30 min, via la tarea programada "BootWhatsapp exportar fotos"
(la crea exportar_fotos_temporal.ps1 / schtasks). Tambien se puede correr a
mano:  .venv\Scripts\python.exe C:\BootWhatsapp\exportar_fotos_temporal.py
"""
import os
import shutil
import sys

sys.path.insert(0, r"c:\BootWhatsapp\Backend\bootwhatsapp")
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core.settings")
django.setup()

from django.utils import timezone
from django.db.models import Count, Max, Q
from chat.models import VehicleEntry

DESTINO = r"C:\FotosVehiculos\temporal"
CACHE_VERDICTOS = r"C:\BootWhatsapp\logs\exportar_fotos_cache.json"

# ── Filtro de DOCUMENTOS (pedido del dueño 2026-07-30) ────────────────────────
# A la carpeta solo van POSICIONES del carro: si una cédula, un oficio o un
# papel quedó archivado por error en un cajón de ángulo, NO se exporta (y si ya
# se había exportado, se borra). El criterio vive en el backend
# (vehicle_intake.es_documento_papel — el MISMO guardián que ya impide
# archivarlos): una sola fuente de verdad.


def _es_documento(path) -> bool:
    try:
        from chat.services.vehicle_intake import es_documento_papel
        return es_documento_papel(path)
    except Exception:
        return False


def _cargar_cache() -> dict:
    import json
    try:
        with open(CACHE_VERDICTOS, encoding='utf-8') as fh:
            return json.load(fh)
    except Exception:
        return {}


def _guardar_cache(cache) -> None:
    import json
    try:
        with open(CACHE_VERDICTOS, 'w', encoding='utf-8') as fh:
            json.dump(cache, fh)
    except Exception:
        pass

# Mismo vocabulario de posiciones que ya usa la carpeta temporal.
ANGULO_NOMBRE = {
    "delantera": "delantera", "posterior": "posterior",
    "lateral_der": "lateral_derecha", "lateral_izq": "lateral_izquierda",
    "motor": "motor", "interior_1": "interior1", "interior_2": "interior2",
    "interior_3": "interior3", "baul": "baul", "repuesto": "repuesto",
    "kilometraje": "kilometraje", "llaves": "llaves",
}
MOMENTO_NOMBRE = {"ingreso": "entrada", "salida": "salida"}


def main() -> int:
    os.makedirs(DESTINO, exist_ok=True)
    # TODAS las fichas con fotos — sin ventana de tiempo ("siempre" es siempre).
    # Tambien las que SOLO tienen formato de inventario (sin fotos de posiciones):
    # su formato igual debe salir a la carpeta (pedido del dueno 2026-07-31).
    con_formato = (Q(inventory_image__isnull=False) & ~Q(inventory_image="")) | \
                  (Q(inventory_doc__isnull=False) & ~Q(inventory_doc=""))
    entries = (VehicleEntry.objects
               .annotate(n_fotos=Count("photos"), ultima=Max("photos__created_at"))
               .filter(Q(n_fotos__gt=0) | con_formato)
               .order_by("-ultima"))

    copiadas = 0
    fichas = 0
    documentos_fuera = 0
    cache = _cargar_cache()  # verdicto es_documento por VehiclePhoto.pk (las fotos no cambian)
    for e in entries:
        placa = (e.placa or "").upper() or "ID{}".format(e.pk)
        fichas += 1
        por_angulo = {}
        for p in e.photos.all().order_by("angle"):
            if not p.file:
                continue
            actual = por_angulo.get(p.angle)
            if actual is None or (actual.moment != "ingreso" and p.moment == "ingreso"):
                por_angulo[p.angle] = p
        for angle, p in sorted(por_angulo.items()):
            try:
                origen = p.file.path
                if not os.path.exists(origen):
                    continue
                ext = os.path.splitext(origen)[1].lower() or ".jpg"
                nombre = "{}_inventario_{}_{}{}".format(
                    placa, ANGULO_NOMBRE.get(angle, angle),
                    MOMENTO_NOMBRE.get(p.moment, p.moment), ext)
                destino = os.path.join(DESTINO, nombre)
                # ¿Es un documento (cédula/papel) mal archivado como posición?
                clave = str(p.pk)
                if clave not in cache:
                    cache[clave] = _es_documento(origen)
                if cache[clave]:
                    documentos_fuera += 1
                    if os.path.exists(destino):
                        os.unlink(destino)  # ya se había exportado: fuera
                    print("  DOCUMENTO fuera de la carpeta: {} ({})".format(
                        nombre, ANGULO_NOMBRE.get(angle, angle)))
                    continue
                # Solo copiar si cambio (mismo tamano = misma foto: no re-copiar
                # 1.000+ archivos cada 30 minutos).
                if (not os.path.exists(destino)
                        or os.path.getsize(destino) != os.path.getsize(origen)):
                    shutil.copy2(origen, destino)
                    copiadas += 1
            except Exception:
                pass  # una foto rota no debe frenar el resto
        # Foto del FORMATO: version imagen si existe; el documento original
        # solo cuando ya es imagen (un PDF no es "foto").
        try:
            src = None
            if e.inventory_image:
                src = e.inventory_image.path
            elif e.inventory_doc and os.path.splitext(e.inventory_doc.name)[1].lower() in (
                    ".png", ".jpg", ".jpeg", ".webp"):
                src = e.inventory_doc.path
            if src and os.path.exists(src):
                ext = os.path.splitext(src)[1].lower() or ".png"
                # El formato va con el mismo patron que las posiciones
                # (pedido del dueno 2026-07-31): {PLACA}_inventario_inventario_entrada.{ext}
                destino = os.path.join(
                    DESTINO, "{}_inventario_inventario_entrada{}".format(placa, ext))
                # Nombre anterior ({PLACA}_formato.{ext}): fuera para no duplicar.
                viejo = os.path.join(DESTINO, "{}_formato{}".format(placa, ext))
                if os.path.exists(viejo):
                    os.unlink(viejo)
                if (not os.path.exists(destino)
                        or os.path.getsize(destino) != os.path.getsize(src)):
                    shutil.copy2(src, destino)
                    copiadas += 1
        except Exception:
            pass

    _guardar_cache(cache)
    print("{:%Y-%m-%d %H:%M} | fichas revisadas={} | archivos nuevos/actualizados={} | documentos excluidos={}".format(
        timezone.localtime(), fichas, copiadas, documentos_fuera))
    return 0


if __name__ == "__main__":
    sys.exit(main())
