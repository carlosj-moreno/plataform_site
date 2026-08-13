# Asciende lider.gestores a ADMIN pleno (lo ejecuta el dueño, una sola vez).
# Admin real: ve TODOS los chats, Numeros Puente, Configurar Bot, Mi Equipo
# completo (crea cualquier rol de su equipo) y Pagos de Capturas. El menu
# queda enfocado en lo que va a usar; el mismo puede reactivar el resto en
# Configuracion -> Herramientas (en un admin lo oculto NO quita acceso).
#
# Uso (PowerShell):
#   cd C:\BootWhatsapp\Backend\bootwhatsapp
#   .\.venv\Scripts\python.exe C:\BootWhatsapp\hacer_admin_lider.py
import os

import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.contrib.auth import get_user_model          # noqa: E402
from chat.services.permissions import ALL_KEYS          # noqa: E402

u = get_user_model().objects.get(username='lider.gestores')
p = u.userprofile
p.role = 'admin'
p.secondary_role = ''
p.permissions = {}   # admin: todo-True; el recorte de menu vive en hidden_tools
VISIBLES = {'inbox', 'dashboard', 'reports', 'connections', 'team',
            'prompt_generator', 'pagos_capturas'}
p.hidden_tools = [k for k in ALL_KEYS if k not in VISIBLES]
p.save()
print('Listo: lider.gestores ahora es ADMIN.')
print('Menu visible:', ', '.join(sorted(VISIBLES)))
print('(Recarga con Ctrl+F5 y vuelve a iniciar sesion.)')
