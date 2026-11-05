# 03 · Instagram e Facebook (Messenger)

As duas caixas usam um **app do Meta** seu, criado em developers.facebook.com, do tipo **Empresa** e ligado ao seu portfólio empresarial.

1. No app, adicione os casos de uso **Messenger** (para a Página) e **Instagram (mensagens)**.
2. **Facebook:** no CRM, abra **Configurações › Admin › Canais › Facebook** e preencha `FB_APP_ID`, `FB_APP_SECRET` e um `FB_VERIFY_TOKEN` inventado (uma senha longa). No app do Meta, em Messenger › Webhooks, use a URL `https://api-crm.seudominio/bot` e o mesmo verify token. Assine `messages`, `messaging_postbacks` e `message_reads`.
3. **Instagram:** em **Configurações › Admin › Canais › Instagram**, preencha `INSTAGRAM_APP_ID`, `INSTAGRAM_APP_SECRET` e `INSTAGRAM_VERIFY_TOKEN`. No app do Meta, o webhook do Instagram é `https://api-crm.seudominio/webhooks/instagram`.
4. Na caixa de entrada, use **Canais › Novo canal › Facebook** ou **Instagram** e faça login com a conta que administra a Página ou o perfil profissional.
5. Enquanto o app estiver em modo de desenvolvimento, só quem tem função no app (administrador, desenvolvedor ou testador) consegue conversar. Para o público, publique o app e passe pela análise do Meta (`pages_messaging`, `instagram_manage_messages`).

**Comentários:** para responder comentários com DM e link rastreado, o OpenReply (open source) faz isso. Use os links com código `[O…]`, como mostra o guia 08.
