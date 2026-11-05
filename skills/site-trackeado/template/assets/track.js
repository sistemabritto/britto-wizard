/* Site trackeado (britto-wizard): origem do contato e medição de anúncios.
 * 1) Origem (sem cookies, só nesta aba): quem chega por anúncio do Google (gclid ou utm cpc) tem o
 *    código da mensagem trocado de [S...] para [G...]; anúncio do Meta (utm paga de facebook/instagram)
 *    vira [...] sem prefixo. O CRM lê esse código na primeira mensagem do WhatsApp.
 * 2) Medição (só com aceite): Pixel do Meta e tag do Google Ads, com PageView e Contact no clique do
 *    WhatsApp. Sem aceite nada é carregado. "Preferências de cookies" no rodapé reabre a escolha.
 */
(function () {
  var el = document.currentScript, ds = (el && el.dataset) || {};
  var cfg = { metaPixel: ds.metaPixel, googleTag: ds.googleTag, googleConversion: ds.googleConversion, privacy: ds.privacy, clickUrl: ds.clickUrl };
  var KEY = 'site_consent', SRC = 'site_src';
  var q = new URLSearchParams(location.search);
  var get = function (k) { return (q.get(k) || '').toLowerCase(); };

  function detect() {
    var src = get('utm_source'), med = get('utm_medium');
    var paid = /^(cpc|ppc|paid|paid_social|paidsocial|ads?|cpm)$/.test(med);
    if (q.get('gclid') || q.get('gbraid') || q.get('wbraid') || (paid && /google|youtube/.test(src))) return 'G';
    if (paid && /^(facebook|fb|instagram|ig|meta)$/.test(src)) return 'M';
    return null;
  }
  var store = {
    get: function (s, k) { try { return window[s].getItem(k); } catch (e) { return null; } },
    set: function (s, k, v) { try { if (v === null) window[s].removeItem(k); else window[s].setItem(k, v); } catch (e) { /* modo privado */ } }
  };
  var found = detect();
  if (found) store.set('sessionStorage', SRC, found);
  if (q.get('gclid')) store.set('sessionStorage', 'site_gclid', q.get('gclid'));
  var origin = store.get('sessionStorage', SRC);

  function codeOf(href) {
    try { var t = new URL(href).searchParams.get('text') || ''; var m = t.match(/\[([A-Z]{2,4}\d{1,3})(?:-[A-Z0-9]{5})?\]\s*$/); return m ? m[1] : ''; } catch (e) { return ''; }
  }
  var links = Array.prototype.slice.call(document.querySelectorAll('a[href^="https://wa.me/"]'));
  if (origin) {
    links.forEach(function (a) {
      try {
        var u = new URL(a.href), t = u.searchParams.get('text');
        if (!t) return;
        var nt = t.replace(/\[S([A-Z]{3}\d{1,3})\]\s*$/, function (_, c) { return '[' + (origin === 'G' ? 'G' : '') + c + ']'; });
        if (nt !== t) { u.searchParams.set('text', nt); a.href = u.toString(); }
      } catch (e) { /* link sem texto */ }
    });
  }

  var loaded = false;
  function loadTags() {
    if (loaded) return; loaded = true;
    if (cfg.metaPixel) {
      /* eslint-disable */
      !function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,document,'script','https://connect.facebook.net/en_US/fbevents.js');
      /* eslint-enable */
      window.fbq('init', cfg.metaPixel);
      window.fbq('track', 'PageView');
    }
    if (cfg.googleTag) {
      var s = document.createElement('script'); s.async = true;
      s.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(cfg.googleTag);
      document.head.appendChild(s);
      window.dataLayer = window.dataLayer || [];
      window.gtag = function () { window.dataLayer.push(arguments); };
      window.gtag('js', new Date());
      window.gtag('config', cfg.googleTag);
    }
  }
  links.forEach(function (a) {
    a.addEventListener('click', function () {
      var code = codeOf(a.href), body = code;
      // Com aceite e vindo de anúncio do Google: referência curta na mensagem ([GINV1-AB12C]) e o gclid
      // vão ao CRM, que casa a conversa com o clique (conversões offline no Google Ads).
      var gclid = store.get('sessionStorage', 'site_gclid');
      if (loaded && gclid && /^G/.test(code)) {
        var abc = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789', ref = '';
        for (var i = 0; i < 5; i++) ref += abc.charAt(Math.floor(Math.random() * abc.length));
        try {
          var u = new URL(a.href), t = u.searchParams.get('text') || '';
          u.searchParams.set('text', t.replace(/\[(G[A-Z]{3}\d{1,3})(?:-[A-Z0-9]{5})?\]\s*$/, '[$1-' + ref + ']'));
          a.href = u.toString();
          body = code + ' ' + ref + ' ' + gclid;
        } catch (e) { /* mantém o link */ }
      }
      // Contagem no CRM (sem cookie; o gclid só vai com aceite): vale com ou sem aceite.
      if (cfg.clickUrl && code && navigator.sendBeacon) { try { navigator.sendBeacon(cfg.clickUrl, body); } catch (e) { /* sem rede */ } }
      if (!loaded) return;
      if (window.fbq) window.fbq('track', 'Contact', { content_name: code || 'whatsapp', content_category: location.pathname });
      if (window.gtag && cfg.googleConversion) window.gtag('event', 'conversion', { send_to: cfg.googleConversion });
    });
  });

  function banner() {
    if (!cfg.metaPixel && !cfg.googleTag) return;
    var old = document.getElementById('cookie-banner'); if (old) old.remove();
    var d = document.createElement('div');
    d.id = 'cookie-banner'; d.className = 'cookie-banner'; d.setAttribute('role', 'dialog'); d.setAttribute('aria-label', 'Preferências de cookies');
    d.innerHTML = '<p>Usamos cookies de medição do Meta e do Google para saber quais anúncios trazem contatos. ' +
      'Nada é carregado sem o seu aceite. <a href="' + (cfg.privacy || '/privacidade/') + '#cookies">Saiba mais</a></p>' +
      '<div><button type="button" data-c="no">Recusar</button><button type="button" data-c="yes" class="ok">Aceitar</button></div>';
    d.addEventListener('click', function (e) {
      var c = e.target.getAttribute && e.target.getAttribute('data-c'); if (!c) return;
      store.set('localStorage', KEY, c); d.remove(); if (c === 'yes') loadTags();
    });
    document.body.appendChild(d);
  }
  var pref = document.getElementById('cookie-prefs');
  if (pref) pref.addEventListener('click', function (e) { e.preventDefault(); store.set('localStorage', KEY, null); banner(); });

  var consent = store.get('localStorage', KEY);
  if (consent === 'yes') loadTags(); else if (consent !== 'no') banner();
})();
