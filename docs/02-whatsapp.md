# 02 · WhatsApp (evogo-jud)

O WhatsApp entra pelo **evogo-jud**, fork do Evolution Go. Ele é **não oficial**: lê o QR Code do WhatsApp Business do celular, sem precisar da API oficial do Meta. Use um chip para **aquisição** (comercial) e, se quiser, outro para **suporte**.

1. No CRM: **Configurações › Caixas de entrada › Adicionar › WhatsApp › Evolution Go**.
2. **URL da API:** `https://whatsapp.seudominio`. **Chave (admin token):** valor de `EVOGO_GLOBAL_API_KEY` em `/opt/britto/.env` (`grep EVOGO_GLOBAL_API_KEY /opt/britto/.env`).
3. Dê um nome à caixa, por exemplo `whatsapp-comercial`. Para não misturar contatos, use opções como ignorar grupos e status.
4. Clique para gerar o QR Code e leia no celular: **WhatsApp Business › Dispositivos conectados › Conectar dispositivo**.
5. Repita para o chip de suporte (`whatsapp-suporte`).
6. **Funil de tráfego:** em **Configurações › Admin › Tracking › Caixas de aquisição**, marque **só** a caixa comercial. O suporte fica fora do funil.

**Boas práticas:**
- O celular precisa abrir o WhatsApp de vez em quando, para a sessão não expirar.
- Áudio e foto sem legenda funcionam com os agentes de IA: o wizard instala o patch do processor.
- Não use o mesmo número em dois sistemas ao mesmo tempo.
