# 02 · WhatsApp (evogo-jud)

O WhatsApp entra pelo **evogo-jud**, fork do Evolution Go. Ele é **não oficial**: lê o QR Code do WhatsApp Business do celular, sem precisar da API oficial do Meta. Use um chip para **aquisição** (comercial) e, se quiser, outro para **suporte**.

1. O wizard já deixa o provedor pronto em **Configurações › Admin › Canais** (seção Evolution Go): URL `https://whatsapp.seudominio` e a chave `EVOGO_GLOBAL_API_KEY` do `/opt/britto/.env`. Se instalou de outro jeito, preencha esses dois campos aí.
2. No CRM: **Canais › Novo canal › WhatsApp › provedor Evolution Go**.
3. Dê um nome ao canal (ex.: `whatsapp-comercial`) e marque ignorar grupos/status para não misturar contatos.
4. Clique para gerar o QR Code e leia no celular: **WhatsApp Business › Dispositivos conectados › Conectar dispositivo**.
5. Repita para o chip de suporte (`whatsapp-suporte`).
6. **Funil de tráfego:** em **Configurações › Admin › Tracking › Caixas de aquisição**, marque **só** a caixa comercial. O suporte fica fora do funil.

**Boas práticas:**
- O celular precisa abrir o WhatsApp de vez em quando, para a sessão não expirar.
- Áudio e foto sem legenda funcionam com os agentes de IA: o wizard instala o patch do processor.
- Não use o mesmo número em dois sistemas ao mesmo tempo.
