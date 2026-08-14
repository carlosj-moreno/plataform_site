# Aísla el acceso maestro (auditoría 2026-08-12).
#
# Problema: un superuser de Django ve TODAS las empresas (user_roles /
# effective_permissions le dan admin global), así que los superusers actuales
# veían también "Equipo Capturas". Decisión del dueño: dejar UN solo superuser
# maestro para soporte de la plataforma, y bajar el otro a admin NORMAL de su
# empresa (que solo ve la suya).
#
# Resultado:
#   - Admin (id 9): sigue superuser maestro (dueño de la plataforma).
#   - admin (id 8): pasa a admin normal de Empresa Principal — deja de ver
#     Equipo Capturas y las demás empresas. Se le quita is_superuser Y is_staff
#     (sin lo segundo aún entraría al panel /admin/ de Django).
#
# Uso (PowerShell):
#   cd C:\BootWhatsapp\Backend\bootwhatsapp
#   .\.venv\Scripts\python.exe C:\BootWhatsapp\aislar_superuser.py
import os

import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.contrib.auth import get_user_model  # noqa: E402

User = get_user_model()

MAESTRO = 'Admin'          # id 9 — conserva el acceso global
A_BAJAR = ['admin']        # id 8 — admin normal de su empresa

# Salvaguarda: nunca quedar sin ningún superuser.
maestro = User.objects.filter(username=MAESTRO, is_superuser=True).first()
if maestro is None:
    raise SystemExit(f'ABORTA: no existe el superuser maestro "{MAESTRO}"; '
                     f'no bajo a nadie para no quedar sin acceso global.')

for username in A_BAJAR:
    u = User.objects.filter(username=username).first()
    if u is None:
        print(f'  - {username}: no existe, se omite')
        continue
    u.is_superuser = False
    u.is_staff = False
    u.save(update_fields=['is_superuser', 'is_staff'])
    p = u.userprofile
    # Que sea admin de SU empresa (rol de negocio), no un agente colgado.
    if p.role != 'admin':
        p.role = 'admin'
        p.save(update_fields=['role'])
    print(f'  - {username}: is_superuser=False, is_staff=False, '
          f'rol=admin de empresa {p.company_id} ({getattr(p.company, "name", None)})')

print()
restantes = list(User.objects.filter(is_superuser=True).values_list('username', flat=True))
print('Superusers restantes (acceso global):', restantes)
print('Listo. El superuser maestro sigue viendo todo; el resto solo su empresa.')
print('(Ctrl+F5 y re-login en las cuentas afectadas.)')
