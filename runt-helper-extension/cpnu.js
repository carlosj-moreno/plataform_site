// Consulta Nacional Unificada (consultaprocesos.ramajudicial.gov.co) —
// extensión interna de La Principal. Es la página para VALIDAR el proceso
// (radicación completa, despacho, sujetos, actuaciones).
//
// La ficha del CRM abre /Procesos/Index con los datos en la URL:
//   · ?radicacion=23dígitos → entra solo a "Consulta por número de radicación"
//     y escribe el número.
//   · ?nombre=… (sin radicación) → entra a "Nombre o Razón Social" y lo escribe.
// Es una app Vue: el valor se escribe con el setter nativo + evento input
// (si no, el v-model no se entera) y la navegación interna se vigila con un
// MutationObserver permanente. El botón Consultar queda para el humano.

(function () {
  'use strict';

  function paramDeLaUrl(nombre) {
    const s = new URLSearchParams(location.search).get(nombre);
    if (s) return s.trim();
    const hash = (location.hash || '').replace(/^#/, '');
    const q = hash.indexOf('?');
    if (q >= 0) {
      const v = new URLSearchParams(hash.slice(q + 1)).get(nombre);
      if (v) return v.trim();
    }
    return '';
  }

  const radicacionDeLaUrl = () => paramDeLaUrl('radicacion').replace(/\D/g, '');
  const nombreDeLaUrl = () => paramDeLaUrl('nombre');

  const norm = (t) => (t || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .trim();

  function firma(el) {
    const attrs = ['id', 'name', 'placeholder', 'aria-label', 'title']
      .map((a) => el.getAttribute(a) || '')
      .join(' ');
    let label = '';
    if (el.id) {
      const l = document.querySelector(`label[for="${el.id}"]`);
      if (l) label = l.textContent || '';
    }
    return norm(attrs + ' ' + label);
  }

  // Vue (v-model) ignora asignar .value a secas: hay que usar el setter
  // NATIVO del input y disparar 'input' para que el modelo lo tome.
  function escribirVue(el, valor) {
    if (!el || !valor) return;
    const setter = Object.getOwnPropertyDescriptor(
      window.HTMLInputElement.prototype, 'value').set;
    setter.call(el, valor);
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
  }

  let navegado = false;   // un solo clic de navegación por carga

  function intentar() {
    const rad = radicacionDeLaUrl();
    const nom = nombreDeLaUrl();
    if (!rad && !nom) return;   // abierta a mano: nada que hacer

    const path = norm(location.pathname + location.hash);

    // En el menú (Index u otra vista): entrar a la consulta que corresponda.
    if (!/numeroradicacion|nombrerazonsocial/.test(path)) {
      if (navegado) return;
      const enlaces = Array.from(document.querySelectorAll('a, button'));
      const objetivo = rad
        ? enlaces.find((a) => /numeroradicacion/i.test(a.getAttribute('href') || '')
            || /numero de radicaci/.test(norm(a.textContent)))
        : enlaces.find((a) => /nombrerazonsocial/i.test(a.getAttribute('href') || '')
            || /nombre o razon social/.test(norm(a.textContent)));
      if (objetivo) {
        navegado = true;
        objetivo.click();
      }
      return;
    }

    // En la vista de consulta: escribir el dato UNA vez por render (la marca
    // en el elemento evita pelear con la máscara/formato que aplique Vue).
    const inputs = Array.from(
      document.querySelectorAll('input[type="text"], input:not([type])'))
      .filter((i) => !i.disabled && i.offsetParent !== null && !i.dataset.crmLleno);
    if (!inputs.length) return;

    if (/numeroradicacion/.test(path) && rad) {
      const campo = inputs.find((i) => /radicaci|23\s*d/.test(firma(i))) || inputs[0];
      escribirVue(campo, rad);
      campo.dataset.crmLleno = '1';
    } else if (/nombrerazonsocial/.test(path) && nom) {
      const campo = inputs.find((i) => /nombre|razon/.test(firma(i))) || inputs[0];
      escribirVue(campo, nom);
      campo.dataset.crmLleno = '1';
    }
  }

  // SPA: el DOM cambia al navegar entre vistas — observar siempre, con los
  // guards de arriba para no repetir clics ni re-escrituras.
  const obs = new MutationObserver(() => intentar());
  obs.observe(document.documentElement, { childList: true, subtree: true });
  window.addEventListener('popstate', () => {
    navegado = false;
    intentar();
  });
  intentar();
})();
