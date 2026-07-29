// Consulta asistida del catálogo DIAN — extensión interna de La Principal.
//
// El CRM abre el catálogo con el CUFE ya diligenciado por la propia DIAN
// (query ?DocumentKey=) y manda el NIT en el FRAGMENTO de la URL (#nit=…),
// porque desde jul-2026 el formulario exige también el "NIT del Emisor o
// Receptor" y su servidor NO lo acepta por query string (solo bindea
// DocumentKey). El fragmento nunca viaja al servidor: este script lo lee y
// escribe el NIT en el campo. El captcha (Cloudflare Turnstile) y el botón
// Buscar quedan para el humano — igual que en el RUNT, eso no se toca.

(function () {
  'use strict';

  function nitDeLaUrl() {
    const hash = (location.hash || '').replace(/^#/, '');
    const v = new URLSearchParams(hash).get('nit') || '';
    // Solo dígitos (el formulario pide el NIT sin puntos, comas, ni DV; el
    // CRM ya lo manda limpio — esto es un cinturón extra).
    return v.replace(/\D/g, '');
  }

  function escribir(el, valor) {
    if (!el || !valor || el.value === valor) return;
    el.focus();
    el.value = valor;
    // jQuery validate + el script propio de la página escuchan 'input'.
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
    el.blur();
  }

  function intentar() {
    const nit = nitDeLaUrl();
    if (!nit) return true;   // abierta a mano, nada que hacer
    const campo = document.getElementById('SearchDocumentNit');
    if (!campo) return false;
    // La página oculta el bloque del NIT hasta que DocumentKey tiene valor;
    // con el CUFE prefijado ya lo muestra, pero se asegura por si acaso.
    const bloque = document.getElementById('search-document-nit-container');
    if (bloque) bloque.style.display = '';
    escribir(campo, nit);
    return true;
  }

  // La página es server-rendered (no SPA), pero por robustez se reintenta
  // brevemente si el DOM aún no está listo y al cambiar el fragmento.
  function arrancar() {
    if (intentar()) return;
    const obs = new MutationObserver(() => {
      if (intentar()) obs.disconnect();
    });
    obs.observe(document.documentElement, { childList: true, subtree: true });
    setTimeout(() => obs.disconnect(), 15000);
  }

  window.addEventListener('hashchange', arrancar);
  arrancar();
})();
