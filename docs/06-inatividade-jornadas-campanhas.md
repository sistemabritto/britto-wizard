# 06 · Inatividade, jornadas e campanhas

Existem **três** automações diferentes. Use cada uma para o que ela faz bem.

## Ações de inatividade (conversa parada)
- **No agente de IA**, em **Agentes de IA › agente › Ações de inatividade**: "se o cliente não responder em X minutos, mande Y". Encadeie, por exemplo, 30 min de lembrança gentil e 24 h de "vou encerrar por aqui, é só chamar". Funciona em conversa aberta ou pendente, sem humano atribuído.
- **Na caixa**, em **Configurações › Caixas de entrada › caixa › Inatividade**, há um gatilho por minutos de inatividade. Use para o canal todo.

## Inatividade da etapa (card parado no pipeline)
Em **Pipelines › pipeline › etapa › editar**, configure o tempo máximo na etapa (por exemplo "Documentação pendente" há mais de 3 dias). Ao estourar, cria uma tarefa ou envia uma mensagem. Ótimo para não esquecer cliente.

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
Em **Configurações › Automações**: "quando X acontecer e Y for verdade, faça Z". Exemplos: o opt-out e atribuir ao advogado quando a etiqueta `prioridade-humano` for aplicada.
