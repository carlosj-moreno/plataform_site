# Separa la operacion de Pagos de Capturas en SU PROPIA EMPRESA (tenant).
# Crea la empresa "Equipo Capturas" y mueve a ella al lider y a sus gestores.
# Resultado: su admin ve SOLO su equipo, sus lineas, su bot y sus pagos —
# y deja de ver el equipo, el prompt y los chats de Empresa Principal
# (y viceversa: el aislamiento por empresa aplica en ambas direcciones).
#
# Uso (PowerShell):
#   cd C:\BootWhatsapp\Backend\bootwhatsapp
#   .\.venv\Scripts\python.exe C:\BootWhatsapp\separar_equipo_capturas.py
import os

import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.contrib.auth import get_user_model  # noqa: E402
from chat.models import Company                 # noqa: E402

MIEMBROS = ('lider.gestores', 'gestor.capturas')

co, created = Company.objects.get_or_create(name='Equipo Capturas')
print(f'Empresa: {co.name} (id={co.id}) {"creada" if created else "ya existia"}')

for username in MIEMBROS:
    u = get_user_model().objects.filter(username=username).first()
    if u is None:
        print(f'  - {username}: NO existe, se omite')
        continue
    p = u.userprofile
    p.company = co
    # El lider queda admin de SU empresa; ya no necesita menu recortado:
    # en su tenant no hay secciones ajenas que estorben.
    if p.role == 'admin':
        p.hidden_tools = []
    p.save(update_fields=['company', 'hidden_tools'])
    print(f'  - {username}: movido a "{co.name}" (rol {p.role})')

print()
print('Listo. Ctrl+F5 y re-login. Pasos siguientes dentro de "Equipo Capturas":')
print('  1. Numeros Puente -> nueva linea QR (un celular que este EN el grupo)')
print('     y activarle "Procesando mensajes de grupos".')
print('  2. Cuando el grupo aparezca en la Bandeja -> ficha del chat ->')
print('     activar "Fuente de pagos de capturas".')
print('  3. Mi Equipo -> crear los gestores que falten (rol Gestor).')
