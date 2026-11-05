# 08 · Tráfego: pixel, CAPI e Google Ads no painel /trafego

O painel fica em **CRM › Tráfego**. Ele mostra o funil clique → conversa → link de agendamento → reunião → contrato → pagamento, por origem (Meta, Google, site, Instagram, Postiz, OpenReply), com custos e ROAS. A configuração fica em **Configurações › Admin › Tracking**.

## Como a origem é reconhecida
A mensagem pronta do WhatsApp termina com um código:

| Código | Origem |
|---|---|
| `[INV1]` (sem prefixo) | anúncio do Meta |
| `[GINV1]` | Google |
| `[SINV1]` | site orgânico |
| `[PINV1]` | Postiz |
| `[OINV1]` | OpenReply |
| `[IG1]` | Instagram orgânico |

Gere os links em **Tracking › Gerador de links** ou com `trafego_links` no MCP. O anúncio de clique para WhatsApp do Meta também é reconhecido pelo dado de anúncio que o WhatsApp envia.

## Meta: token, pixel e API de Conversões
1. **Pixel:** em Gerenciador de Eventos › Conectar fontes de dados › Web, crie o pixel. Copie o ID para **Tracking › Meta › ID do pixel**.
2. **Token da CAPI:** no pixel, em Configurações › API de Conversões › **Gerar token de acesso**. Cole em **Token da API de Conversões** e ligue o switch **CAPI**. A CAPI envia só contatos vindos do Meta, do site, do Instagram, do Postiz e do OpenReply, com telefone e e-mail em hash.
3. **Token de leitura (gasto e cliques):** em business.facebook.com/settings:
   - **Usuários do sistema › Adicionar**, com função **Funcionário** (a de Admin pode ficar bloqueada por 7 dias em portfólio novo);
   - **Atribuir ativos**: o app (Gerenciar app) e a conta de anúncios (Ver desempenho);
   - **Gerar token** com `ads_read`, validade Nunca.

   Cole em **Token de acesso** junto com o ID da conta de anúncios. A sincronização roda a cada 3 h.

## Google Ads: tag, script e conversões offline
1. **Tag do site:** em Metas › Conversões › Nova › Site › **Contato**, use valor fixo 1 e contagem Uma. O ID `AW-…` e o rótulo vão no site (guia 09).
2. **Gasto e cliques:** em **Tracking › Google Ads**, clique em "Gerar chave" e salve. Copie o script mostrado e cole em Google Ads › Ferramentas › Ações em massa › **Scripts**. Clique em **Autorizar** e **Executar**, e mude a frequência para **Por hora**. No Linux, se o Google pedir chave de acesso por Bluetooth, autorize pelo Chrome do celular em "versão para computador".
3. **Conversões offline (reunião, contrato, pagamento):** gere a **senha da planilha** em Tracking.
   - No Google Ads, abra Metas › Conversões › Nova › **Conversões off-line › HTTPS**.
   - URL `https://api-crm.seudominio/api/v1/webhooks/tracking/google_conversions.csv`, usuário `google` e a senha gerada. Aceite a declaração de dados do cliente.
   - Crie 3 ações, filtrando `Conversion_Name` igual a:

| Ação | Categoria | Valor |
|---|---|---|
| `Reunião agendada` | Lead qualificado | padrão R$ 1 |
| `Contrato assinado` | Lead convertido | padrão R$ 1 |
| `Pagamento efetuado` | Compra | valor da planilha |

O mapeamento de colunas (gclid, e-mail e telefone em hash) é automático. A linha "Exemplo (ignorar)" da planilha só existe para o Google reconhecer as colunas.

## Pagamento e contrato automáticos
O conector MCP recebe os webhooks do **Asaas** (`PAYMENT_RECEIVED`/`PAYMENT_CONFIRMED`) e do **DocuSeal** (`submission.completed`). Com eles, os marcos de pagamento e contrato entram no funil sozinhos.
