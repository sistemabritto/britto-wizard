# 05 · Agentes de IA (secretária virtual)

1. **Credencial:** em **Agentes de IA › Credenciais**, cadastre a chave da OpenAI. `gpt-4o-mini` é barato e transcreve áudio.
2. **Agente:** em **Agentes de IA › Novo**, use o tipo LLM e o modelo `gpt-4o-mini`. No prompt:
   - quem é o escritório e as áreas atendidas;
   - o tom de voz;
   - o que **nunca** fazer: dar parecer jurídico, prometer resultado, informar preço sem autorização;
   - o roteiro de triagem: aceite LGPD, nome, cidade, assunto, documentos;
   - quando chamar um humano.
3. **Ligar à caixa:** no agente, em **Caixas de entrada**, escolha a caixa comercial. A caixa de suporte pode ter outro agente ou nenhum.
4. **Pausa humana:** quando a equipe assume, aplique a etiqueta `bot-pausado`; o agente para de responder. Remova a etiqueta para devolver a conversa à IA. A etiqueta `equipe` marca contatos internos, que a IA ignora e ficam fora do funil.
5. **Horário:** em **Configurações › Caixas de entrada › Horário de funcionamento**, defina a mensagem fora do horário.
6. **Ações de inatividade do agente:** em **Agentes de IA › agente › Ações de inatividade**, programe o que fazer quando o cliente some no meio da triagem. Por exemplo, uma lembrança depois de 60 min e o encerramento depois de 24 h. Veja o guia 06.

**Dicas:** teste com um número seu antes de ligar no chip comercial. Use as macros "Documento recebido" e "Encerrar atendimento" que o template criou.
