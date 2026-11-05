---
name: site-trackeado
description: Cria o site institucional de um escritório/negócio num repositório do GitHub, já rastreado para o painel /trafego do evo-jud-crm (códigos de origem no WhatsApp, Pixel do Meta e tag do Google só após aceite de cookies, contagem anônima de cliques, gclid para conversões offline, política de privacidade e CSP). Use quando pedirem "criar o site", "landing page com WhatsApp rastreado" ou "site trackeado".
---

# Site trackeado (britto-wizard)

Gera um site estático simples (HTML + CSS, sem framework) a partir de `template/`, publica num repositório do GitHub do usuário e deixa pronto para servir na VPS (Nginx/Traefik) ou no GitHub Pages.

## Antes de começar, pergunte (uma vez só)
1. Nome do negócio, áreas/serviços (vira uma página por área) e tom de voz.
2. Número do WhatsApp comercial (DDI+DDD+número).
3. Domínio do site e do CRM (`api-crm.<domínio>` para a contagem de cliques).
4. Se já tem: ID do Pixel do Meta, `AW-…` e rótulo da conversão "Contato WhatsApp" do Google Ads (pode ficar vazio e preencher depois).
5. Nome do repositório no GitHub (padrão: `site-<negocio>`), público ou privado.

## Passos
1. Copie `template/` desta skill para uma pasta nova do projeto.
2. Edite **só** o bloco `CONFIG` e a lista `PAGES` em `build.py`:
   - cada página tem `mensagem` (frase pronta do WhatsApp) e `codigo` = `S` + área em 3 letras maiúsculas + variação (ex.: `SINV1`, `SDIV1`, `SGER1`). **O código é obrigatório** e precisa ser único por página/botão;
   - áreas sugeridas (iguais às do CRM): GER, INV, DIV, IMO, EXT, PRE, CIV, ELE, AGR, AMB, ADM.
3. Escreva os textos das páginas com o usuário. Para advocacia: sem promessa de resultado, sem preço, sem depoimento inventado (Provimento 205/2021 da OAB).
4. Ajuste `src/privacidade.html` com o responsável e o contato de privacidade (mantenha a seção `#cookies`).
5. `python3 build.py` e confira `dist/` no navegador (`python3 -m http.server -d dist`).
6. Crie o repositório e envie (peça confirmação antes de criar/publicar): `gh repo create <nome> --private --source . --push`.
7. Publicação:
   - **VPS (recomendado):** sirva `dist/` com Nginx atrás do Traefik e aplique o cabeçalho `Content-Security-Policy` de `csp.txt` (troque `API_CRM_HOST`). Sem essa CSP o pixel/tag/contagem não carregam.
   - **GitHub Pages:** funciona, mas sem cabeçalhos CSP próprios.

## O que o `track.js` faz (não remova)
- Troca `[S…]` por `[G…]` (gclid ou utm cpc do Google) ou `[…]` (utm paga de facebook/instagram) na mensagem; o CRM lê o código na 1ª mensagem.
- Aviso de cookies: Pixel do Meta (PageView, Contact no clique) e tag do Google Ads (conversão no clique) **só depois do Aceitar**.
- Conta cada clique no WhatsApp no CRM (`click_url`), anônimo, com ou sem aceite.
- Com aceite e vindo do Google: acrescenta uma referência (`[GINV1-AB12C]`) e envia o gclid ao CRM, que liga a conversa ao clique (conversões offline).

## Teste final
Abra o site com `?gclid=teste`, aceite os cookies, clique no WhatsApp: o link deve terminar em `[G…-XXXXX]` e o DevTools deve mostrar `facebook.com/tr` (se houver pixel), `googleadservices`/`1p-conversion` (se houver tag) e um POST para `site_click` sem erro de CSP.
