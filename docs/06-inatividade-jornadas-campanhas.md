# 06 · Inatividade, jornadas e campanhas

Existem **três** automações diferentes. Use cada uma para o que ela faz bem.

## Ações de inatividade (conversa parada)
- **No agente de IA**, em **Agentes de IA › agente › Ações de inatividade**: "se o cliente não responder em X minutos, mande Y". Encadeie, por exemplo, 30 min de lembrança gentil e 24 h de "vou encerrar por aqui, é só chamar". Funciona em conversa aberta ou pendente, sem humano atribuído.
- **Na caixa**, em **Canais › canal › configurações › Inatividade (Gatilho de Inatividade / Minutos de Inatividade)**, há um gatilho por minutos de inatividade. Use para o canal todo.

## Regras de automação da etapa (inclusive inatividade)
Em **Pipelines › pipeline › etapa › Editar Etapa › Regras de Automação › Adicionar Regra**: **Quando** → **Então**.
- Gatilhos: *Etiqueta adicionada*, *Status da conversa alterado*, *Atributo personalizado atualizado* e **Por inatividade**, com base em *Cliente sem responder* ou *Parado na etapa* (minutos, horas ou dias).
- Ações: *Mover para etapa*, *Mover para outro pipeline*, *Atribuir agente*, *Aplicar etiqueta*, *Mensagem via agente de IA*, *Mensagem direta*, *Enviar template*, *Finalizar atendimento*.
- Exemplos: em "Documentação pendente", *Parado na etapa* por 3 dias → *Mensagem via agente de IA* ("lembre o cliente dos documentos"). Em "Proposta de honorários", *Cliente sem responder* por 2 dias → *Aplicar etiqueta* `aguardando-retorno` + *Atribuir agente*.

## Jornadas (Flow) com gatilho de pipeline
Em **Jornadas › Nova jornada**, o gatilho pode ser **Stage do Pipeline Alterado**, **Etiqueta** aplicada ou removida, ou **Formulário enviado**. Exemplos para o jurídico:
- **Contratado** → boas-vindas com a lista de documentos e, 2 dias depois, uma pergunta se ficou alguma dúvida;
- **Reunião agendada** → lembrete na véspera com o link da videochamada;
- etiqueta **documento-recebido** → aviso de recebimento e encaminhamento para a equipe.

## Campanhas (envio em massa)
Em **Campanhas › Nova**, escolha o público por etiqueta ou segmento, a caixa e a mensagem.
- No **WhatsApp não oficial**, mande pouco e para quem já conversou com você, para não ter o número bloqueado.
- **Respeite o opt-out:** o template já cria a automação "Opt-out · Sair/Parar", que marca `nao_contatar`. Exclua esses contatos das campanhas.

## Regras simples (Automações)
Em **Automações**: "quando X acontecer e Y for verdade, faça Z". Exemplos: o opt-out e atribuir ao advogado quando a etiqueta `prioridade-humano` for aplicada.
