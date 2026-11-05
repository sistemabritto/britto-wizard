# 09 · Site com rastreamento (skill)

A skill [`skills/site-trackeado`](../skills/site-trackeado/SKILL.md) ensina o Claude Code a criar um site institucional estático num repositório do GitHub, já com:
- botões de WhatsApp com mensagem pronta e código `[S…]`, trocado sozinho para `[G…]` ou `[…]` quando o visitante vem de anúncio;
- aviso de cookies: o **Pixel do Meta** e a **tag do Google Ads** só carregam depois do aceite;
- contagem anônima de cliques no WhatsApp para o painel `/trafego`, sem cookie;
- gclid ligado à conversa, para as conversões offline do Google;
- política de privacidade com a seção de cookies e da API de Conversões;
- CSP pronta para Nginx/Traefik.

Para instalar a skill no Claude Code: copie a pasta para `~/.claude/skills/site-trackeado` e peça "crie o site do escritório com a skill site-trackeado".
