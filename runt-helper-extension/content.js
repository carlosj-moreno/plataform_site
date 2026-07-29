// Consulta asistida del RUNT — extensión interna de La Principal.
//
// La ficha del CRM abre el portal con la placa y la cédula del PROPIETARIO en
// la URL (?placa=ABC123&cedula=123456 — la cédula sale de la licencia de
// tránsito que la IA ya leyó). Este script las escribe en el formulario de la
// consulta ciudadana; si el CRM no mandó cédula, rellena el último documento
// consultado en este equipo como respaldo. El captcha y el botón Consultar
// quedan para el humano: eso es lo que el RUNT exige y esta extensión NO lo
// toca.

(function () {
  'use strict';

  // Los datos pueden venir antes del # (?placa=X#/ruta) o dentro del hash
  // (#/ruta?placa=X): se aceptan ambos por si el router del portal reescribe.
  function paramDeLaUrl(nombre) {
    const s = new URLSearchParams(location.search).get(nombre);
    if (s) return s.trim();
    const hash = location.hash || '';
    const q = hash.indexOf('?');
    if (q >= 0) {
      const v = new URLSearchParams(hash.slice(q + 1)).get(nombre);
      if (v) return v.trim();
    }
    return '';
  }

  const placaDeLaUrl = () => paramDeLaUrl('placa').toUpperCase();
  // Cédula del PROPIETARIO del vehículo (el RUNT la exige junto a la placa).
  // La manda el CRM, sacada de la licencia de tránsito que la IA ya leyó.
  const cedulaDeLaUrl = () => paramDeLaUrl('cedula').replace(/\D/g, '');

  // "Firma" de un control: sus atributos + el texto del label asociado, en
  // minúsculas y sin tildes. El portal es una SPA que puede cambiar ids entre
  // versiones, así que se busca por significado y no por un selector fijo.
  function firma(el) {
    const attrs = ['id', 'name', 'placeholder', 'formcontrolname', 'aria-label', 'ng-reflect-name']
      .map((a) => el.getAttribute(a) || '')
      .join(' ');
    let label = '';
    if (el.id) {
      const l = document.querySelector(`label[for="${el.id}"]`);
      if (l) label = l.textContent || '';
    }
    if (!label) {
      const wrap = el.closest('label, .form-group, .mat-form-field, div');
      const dentro = wrap && wrap.querySelector('label, mat-label');
      if (dentro) label = dentro.textContent || '';
    }
    return (attrs + ' ' + label)
      .toLowerCase()
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '');
  }

  // Escribe el valor disparando los eventos que el framework del portal
  // (Angular) necesita para enterarse del cambio.
  function escribir(el, valor) {
    if (!el || !valor || el.value === valor) return;
    el.focus();
    el.value = valor;
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
    el.blur();
  }

  function buscarControles() {
    const inputs = Array.from(document.querySelectorAll('input'));
    const selects = Array.from(document.querySelectorAll('select'));
    return {
      placa: inputs.find((i) => /placa/.test(firma(i))),
      documento: inputs.find((i) => {
        const f = firma(i);
        return /(documento|identificacion)/.test(f) && !/tipo/.test(f);
      }),
      tipoDoc: selects.find((s) => {
        const f = firma(s);
        return /tipo/.test(f) && /(documento|identificacion)/.test(f);
      }),
    };
  }

  // Elige "Cédula de ciudadanía" en el selector de tipo de documento, sin
  // depender del value (el portal puede usar ids internos): se busca por el
  // TEXTO de la opción.
  function elegirCedulaCiudadania(sel) {
    const op = Array.from(sel.options).find((o) =>
      /cedula.*ciudadan/.test(
        (o.textContent || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
      ));
    if (op && sel.value !== op.value) {
      sel.value = op.value;
      sel.dispatchEvent(new Event('change', { bubbles: true }));
      sel.dispatchEvent(new Event('input', { bubbles: true }));
    }
  }

  let hecho;

  function intentar() {
    const { placa, documento, tipoDoc } = buscarControles();
    const objetivo = placaDeLaUrl();
    const cedula = cedulaDeLaUrl();

    if (placa && objetivo && !hecho.placa) {
      escribir(placa, objetivo);
      hecho.placa = true;
    }

    // La cédula del PROPIETARIO enviada por el CRM manda; el documento
    // recordado del equipo es solo respaldo cuando la ficha no la tenía.
    if (cedula && !hecho.cedula) {
      if (tipoDoc) elegirCedulaCiudadania(tipoDoc);
      if (documento) {
        escribir(documento, cedula);
        hecho.cedula = true;
      }
    }

    if ((documento || tipoDoc) && !hecho.escucha) {
      hecho.escucha = true;
      // Recordar el último documento consultado en este equipo (respaldo para
      // cuando el CRM no manda cédula; se guarda solo en chrome.storage.local).
      if (documento) {
        documento.addEventListener('change', () =>
          chrome.storage.local.set({ documento: documento.value || '' }));
      }
      if (tipoDoc) {
        tipoDoc.addEventListener('change', () =>
          chrome.storage.local.set({ tipoDoc: tipoDoc.value || '' }));
      }
      if (!cedula) {
        chrome.storage.local.get(['documento', 'tipoDoc'], (g) => {
          if (tipoDoc && g.tipoDoc) escribir(tipoDoc, g.tipoDoc);
          if (documento && g.documento) escribir(documento, g.documento);
        });
      }
    }

    // Terminado cuando el formulario apareció (escucha puesta) y quedó escrito
    // lo que venía en la URL (placa/cédula; sin URL: portal abierto a mano).
    return hecho.escucha && (hecho.placa || !objetivo) && (hecho.cedula || !cedula);
  }

  // El formulario aparece tarde (SPA): se reintenta con un observador hasta
  // lograrlo (máx. ~30 s) y de nuevo si el operador navega dentro del portal.
  function arrancar() {
    hecho = { placa: false, cedula: false, escucha: false };
    if (intentar()) return;
    const obs = new MutationObserver(() => {
      if (intentar()) obs.disconnect();
    });
    obs.observe(document.documentElement, { childList: true, subtree: true });
    setTimeout(() => obs.disconnect(), 30000);
  }

  window.addEventListener('hashchange', arrancar);
  arrancar();
})();
