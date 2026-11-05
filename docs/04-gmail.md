# 04 · Gmail como caixa de entrada

**Opção A, IMAP + SMTP (mais simples):**
1. Na conta Google: **Segurança › Verificação em duas etapas** ligada › **Senhas de app** › crie uma para "CRM".
2. No CRM: **Caixas de entrada › Adicionar › E-mail › Outro provedor**:
   - IMAP `imap.gmail.com`, porta 993, SSL;
   - SMTP `smtp.gmail.com`, porta 587, STARTTLS;
   - usuário: o e-mail; senha: a **senha de app**.

**Opção B, login com Google (OAuth):**
1. No Google Cloud, em **APIs e serviços › Credenciais**, crie um **ID do cliente OAuth › Aplicativo da Web**.
2. Na tela de consentimento, adicione o escopo do Gmail e o seu e-mail como usuário de teste.
3. Em **URIs de redirecionamento**, coloque a URL de callback mostrada em **Configurações › Admin › Google OAuth**, em `GOOGLE_OAUTH_CALLBACK_URL`. Preencha também o client ID e o secret.
4. Crie a caixa **E-mail › Google**.

O conector MCP ainda tem um **processador de e-mails** opcional, `emails_processar`, que separa intimações e publicações e cria tarefas.
