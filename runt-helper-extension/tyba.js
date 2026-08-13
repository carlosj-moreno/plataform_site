// Consulta asistida de TYBA (Rama Judicial / Justicia XXI) — extensión
// interna de La Principal.
//
// La ficha del CRM abre frmConsulta.aspx con los datos en la URL:
//   · ?codigo=23dígitos → pestaña PROCESO: escribe el CÓDIGO y elige el
//     DEPARTAMENTO solo (los 2 primeros dígitos de la radicación son el código
//     DANE). WebForms: elegir departamento dispara su postback normal y el
//     código sobrevive en el viewstate.
//   · ?cedula=… y/o ?nombre=… → pestaña CIUDADANO: elige "Cédula de
//     Ciudadanía", escribe la identificación y reparte el nombre en
//     primer/segundo nombre y apellidos (o Razón Social si es empresa).
// Se diligencian AMBAS pestañas con lo que venga en la URL (los campos de la
// pestaña oculta también existen en el DOM); queda activa la principal:
// Proceso si hay radicación, si no Ciudadano. El Consultar queda para el humano.

(function () {
  'use strict';

  function paramDeLaUrl(nombre) {
    const s = new URLSearchParams(location.search).get(nombre);
    if (s) return s.trim();
    const hash = (location.hash || '').replace(/^#/, '');
    return (new URLSearchParams(hash).get(nombre) || '').trim();
  }

  const codigoDeLaUrl = () => paramDeLaUrl('codigo').replace(/\D/g, '');
  const cedulaDeLaUrl = () => paramDeLaUrl('cedula').replace(/\D/g, '');
  const nombreDeLaUrl = () => paramDeLaUrl('nombre');

  // Código DANE (2 dígitos, inicio de la radicación) → departamento, escrito
  // como para casar con el TEXTO de las opciones del select de TYBA.
  const DANE_DEPARTAMENTOS = {
    '05': 'antioquia', '08': 'atlantico', '11': 'bogota', '13': 'bolivar',
    '15': 'boyaca', '17': 'caldas', '18': 'caqueta', '19': 'cauca',
    '20': 'cesar', '23': 'cordoba', '25': 'cundinamarca', '27': 'choco',
    '41': 'huila', '44': 'guajira', '47': 'magdalena', '50': 'meta',
    '52': 'narino', '54': 'norte de santander', '63': 'quindio',
    '66': 'risaralda', '68': 'santander', '70': 'sucre', '73': 'tolima',
    '76': 'valle', '81': 'arauca', '85': 'casanare', '86': 'putumayo',
    '88': 'san andres', '91': 'amazonas', '94': 'guainia', '95': 'guaviare',
    '97': 'vaupes', '99': 'vichada',
  };

  const norm = (t) => (t || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .trim();

  // Misma "firma" heurística del RUNT: atributos + label, por significado y no
  // por ids fijos (WebForms les antepone prefijos ctl00_… que pueden cambiar).
  function firma(el) {
    const attrs = ['id', 'name', 'placeholder', 'aria-label', 'title']
      .map((a) => el.getAttribute(a) || '')
      .join(' ');
    let label = '';
    if (el.id) {
      const l = document.querySelector(`label[for="${el.id}"]`);
      if (l) label = l.textContent || '';
    }
    if (!label) {
      const wrap = el.closest('.form-group, td, div');
      const dentro = wrap && wrap.querySelector('label');
      if (dentro) label = dentro.textContent || '';
    }
    return norm(attrs + ' ' + label);
  }

  function escribir(el, valor) {
    if (!el || !valor || el.value === valor) return;
    el.focus();
    el.value = valor;
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
    el.blur();
  }

  // Opción del select cuyo texto corresponde al departamento: exacta primero,
  // luego "empieza por", luego "contiene" — así 'santander' NO cae en
  // "norte de santander".
  function opcionDepartamento(sel, nombre) {
    const ops = Array.from(sel.options);
    return (
      ops.find((o) => norm(o.textContent) === nombre) ||
      ops.find((o) => norm(o.textContent).startsWith(nombre)) ||
      ops.find((o) => norm(o.textContent).includes(nombre))
    );
  }

  // Nombre completo → los 4 cajones de TYBA. Con 4+ palabras el reparto es
  // seguro (RONAL ENRIQUE GUZMAN MORALES → nombres RONAL ENRIQUE, apellidos
  // GUZMAN MORALES); con menos es la mejor apuesta y el humano corrige a la
  // vista antes de Consultar.
  function partirNombre(completo) {
    const t = completo.trim().split(/\s+/);
    if (t.length >= 4) {
      return { pn: t[0], sn: t.slice(1, -2).join(' '), pa: t[t.length - 2], sa: t[t.length - 1] };
    }
    if (t.length === 3) return { pn: t[0], sn: '', pa: t[1], sa: t[2] };
    if (t.length === 2) return { pn: t[0], sn: '', pa: t[1], sa: '' };
    return { pn: completo.trim(), sn: '', pa: '', sa: '' };
  }

  const esEmpresa = (n) =>
    /\b(s\.?a\.?s?|ltda|banco|cooperativa|financiera|fondo|leasing|e\.?u)\b\.?/i.test(n);

  function llenarProceso(codigo) {
    const inputs = Array.from(document.querySelectorAll('input[type="text"], input:not([type])'));
    const selects = Array.from(document.querySelectorAll('select'));
    const campoCodigo = inputs.find((i) => /codigo/.test(firma(i)));
    const selDepto = selects.find((s) => /departamento/.test(firma(s)));
    if (!campoCodigo && !selDepto) return false;   // el formulario aún no está

    // 1º el código (textbox sin postback): si el departamento dispara el
    // postback de WebForms, el valor viaja en el POST y el servidor lo
    // re-renderiza — no se pierde.
    if (campoCodigo) escribir(campoCodigo, codigo);

    // 2º el departamento (deducido del DANE de la radicación, o el que mande
    // el CRM en ?departamento=). Si ya está elegido, no volver a disparar el
    // change: eso evita un bucle de postbacks.
    const nombre = norm(paramDeLaUrl('departamento'))
      || DANE_DEPARTAMENTOS[codigo.slice(0, 2)] || '';
    if (selDepto && nombre) {
      const op = opcionDepartamento(selDepto, nombre);
      if (op && selDepto.value !== op.value) {
        selDepto.value = op.value;
        selDepto.dispatchEvent(new Event('change', { bubbles: true }));
      }
    }
    return true;
  }

  function llenarCiudadano(cedula, nombreCompleto, activar) {
    // Las pestañas son tabs de Bootstrap (lado cliente). Los campos existen en
    // el DOM aunque la pestaña esté oculta, así que se pueden llenar sin
    // activarla; solo se ACTIVA cuando esta es la búsqueda principal (sin
    // radicación).
    const tab = document.querySelector('a[href="#Ciudadano"]');
    if (!tab) return false;
    const li = tab.closest('li');
    if (activar && (!li || !li.classList.contains('active'))) tab.click();

    const inputs = Array.from(document.querySelectorAll('input[type="text"], input:not([type])'));
    const campoId = inputs.find((i) => /numero.*identificacion|identificacion/.test(firma(i)));
    if (!campoId) return false;   // la pestaña aún no está

    if (cedula) {
      const selects = Array.from(document.querySelectorAll('select'));
      const selTipo = selects.find((s) => /tipo.*documento/.test(firma(s)));
      if (selTipo) {
        const op = Array.from(selTipo.options)
          .find((o) => /cedula.*ciudadan/.test(norm(o.textContent)));
        if (op && selTipo.value !== op.value) {
          selTipo.value = op.value;
          selTipo.dispatchEvent(new Event('change', { bubbles: true }));
        }
      }
      escribir(campoId, cedula);
    }

    if (nombreCompleto) {
      if (esEmpresa(nombreCompleto)) {
        escribir(inputs.find((i) => /razon/.test(firma(i))), nombreCompleto);
      } else {
        const p = partirNombre(nombreCompleto);
        escribir(inputs.find((i) => /primer.*nombre/.test(firma(i))), p.pn);
        escribir(inputs.find((i) => /segundo.*nombre/.test(firma(i))), p.sn);
        escribir(inputs.find((i) => /primer.*apellido/.test(firma(i))), p.pa);
        escribir(inputs.find((i) => /segundo.*apellido/.test(firma(i))), p.sa);
      }
    }
    return true;
  }

  function intentar() {
    const codigo = codigoDeLaUrl();
    const cedula = cedulaDeLaUrl();
    const nombre = nombreDeLaUrl();
    if (!codigo && !cedula && !nombre) return true;   // abierta a mano

    // AMBAS búsquedas quedan diligenciadas en la misma página: la pestaña
    // Proceso (código + departamento) y la Ciudadano (cédula/nombre). Activa
    // queda la principal: Proceso si hay radicación; si no, Ciudadano.
    let listo = true;
    if (codigo) listo = llenarProceso(codigo) && listo;
    if (cedula || nombre) listo = llenarCiudadano(cedula, nombre, !codigo) && listo;
    return listo;
  }

  // Server-rendered: casi siempre entra a la primera; el observador es el
  // mismo cinturón de seguridad del RUNT por si el DOM llega tarde.
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
