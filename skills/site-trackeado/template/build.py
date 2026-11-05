#!/usr/bin/env python3
"""Site institucional estático com rastreamento (skill site-trackeado do britto-wizard).

Edite só o bloco CONFIG e as páginas em PAGES. Gera ./dist (HTML + assets com hash).
  python3 build.py
"""
import hashlib, html, json, shutil
from pathlib import Path
from urllib.parse import quote

# ======================= CONFIG =======================
CONFIG = {
    'nome': 'Escritório Exemplo',
    'base': 'https://www.exemplo.com.br',
    'privacidade': 'https://www.exemplo.com.br/privacidade/',
    'whatsapp': '5500000000000',                 # DDI + DDD + número, só dígitos
    'meta_pixel': '',                            # ID do pixel do Meta (vazio = sem pixel)
    'google_tag': '',                            # AW-XXXXXXXXX (vazio = sem tag)
    'google_conversion': '',                     # AW-XXXXXXXXX/rotulo da ação "Contato WhatsApp"
    'click_url': 'https://api-crm.exemplo.com.br/api/v1/webhooks/tracking/site_click',  # contagem de cliques no CRM
}
# Código no fim da mensagem: S = site + área (3 letras) + variação. O track.js troca para G (Google) ou sem prefixo (Meta).
PAGES = [
    {'slug': '', 'titulo': 'Início', 'h1': 'Atendimento jurídico com ética e clareza.',
     'texto': 'Conte o seu caso pelo WhatsApp. A primeira triagem é feita pela nossa equipe.',
     'mensagem': 'Olá! Vim pelo site e quero orientação.', 'codigo': 'SGER1'},
    {'slug': 'inventario', 'titulo': 'Inventário', 'h1': 'Inventário e partilha, com orientação em cada etapa.',
     'texto': 'Judicial ou em cartório, organizamos os documentos e o caminho mais adequado.',
     'mensagem': 'Olá! Vim pelo site e quero orientação sobre inventário.', 'codigo': 'SINV1'},
]
# ======================================================

ROOT = Path(__file__).parent
OUT = ROOT / 'dist'


def hashed(path):
    data = (ROOT / path).read_bytes()
    name = Path(path).stem + '.' + hashlib.sha256(data).hexdigest()[:12] + Path(path).suffix
    return name, data


def wa(msg, code):
    return f"https://wa.me/{CONFIG['whatsapp']}?text=" + quote(f'{msg} [{code}]')


def track_tag(js):
    attrs = {'meta-pixel': CONFIG['meta_pixel'], 'google-tag': CONFIG['google_tag'],
             'google-conversion': CONFIG['google_conversion'], 'privacy': CONFIG['privacidade'], 'click-url': CONFIG['click_url']}
    data = ''.join(f' data-{k}="{html.escape(v, quote=True)}"' for k, v in attrs.items() if v)
    return f'<script src="/assets/{js}"{data} defer></script>'


def page(p, css, js):
    e = html.escape
    nav = ''.join(f'<a href="/{q["slug"] + "/" if q["slug"] else ""}">{e(q["titulo"])}</a>' for q in PAGES)
    return f'''<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{e(p["titulo"])} | {e(CONFIG["nome"])}</title><link rel="stylesheet" href="/assets/{css}"></head><body>
<header><strong>{e(CONFIG["nome"])}</strong><nav>{nav}</nav></header>
<main><h1>{e(p["h1"])}</h1><p>{e(p["texto"])}</p>
<a class="btn" href="{e(wa(p["mensagem"], p["codigo"]), quote=True)}" target="_blank" rel="noopener">Falar no WhatsApp</a></main>
<footer><a href="{e(CONFIG["privacidade"])}">Política de privacidade</a> · <a href="#" id="cookie-prefs">Preferências de cookies</a></footer>
{track_tag(js)}</body></html>'''


def build():
    if OUT.exists():
        shutil.rmtree(OUT)
    (OUT / 'assets').mkdir(parents=True)
    css, css_data = hashed('assets/site.css')
    js, js_data = hashed('assets/track.js')
    (OUT / 'assets' / css).write_bytes(css_data)
    (OUT / 'assets' / js).write_bytes(js_data)
    for p in PAGES:
        d = OUT / p['slug'] if p['slug'] else OUT
        d.mkdir(parents=True, exist_ok=True)
        (d / 'index.html').write_text(page(p, css, js), encoding='utf-8')
    priv = (ROOT / 'src/privacidade.html').read_text(encoding='utf-8')
    (OUT / 'privacidade').mkdir(exist_ok=True)
    (OUT / 'privacidade/index.html').write_text(
        page({'slug': 'privacidade', 'titulo': 'Privacidade', 'h1': 'Política de privacidade', 'texto': '',
              'mensagem': 'Olá! Tenho uma dúvida sobre privacidade.', 'codigo': 'SGER9'}, css, js).replace('<p></p>', priv),
        encoding='utf-8')
    print(json.dumps({'paginas': len(PAGES) + 1, 'saida': str(OUT)}))


if __name__ == '__main__':
    build()
