# -*- coding: utf-8 -*-
r"""Exporta a C:\FotosVehiculos\temporal UNA foto por posicion de cada ficha
con fotos recientes (ultimos 2 dias) + la foto del formato de inventario.

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
from django.db.models import Count, Max
from chat.models import VehicleEntry

DESTINO = r"C:\FotosVehiculos\temporal"
DIAS = 2

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
    desde = timezone.now() - timezone.timedelta(days=DIAS)
    entries = (VehicleEntry.objects
               .annotate(n_fotos=Count("photos"), ultima=Max("photos__created_at"))
               .filter(ultima__gte=desde)
               .order_by("-ultima"))

    copiadas = 0
    fichas = 0
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
                destino = os.path.join(DESTINO, "{}_formato{}".format(placa, ext))
                if (not os.path.exists(destino)
                        or os.path.getsize(destino) != os.path.getsize(src)):
                    shutil.copy2(src, destino)
                    copiadas += 1
        except Exception:
            pass

    print("{:%Y-%m-%d %H:%M} | fichas revisadas={} | archivos nuevos/actualizados={}".format(
        timezone.localtime(), fichas, copiadas))
    return 0


if __name__ == "__main__":
    sys.exit(main())
