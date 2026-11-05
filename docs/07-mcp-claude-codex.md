# 07 · MCP: operar o CRM pelo Claude e pelo Codex

O wizard instala o **evocrm-mcp** em `https://mcp.seudominio/mcp`, com login por senha (OAuth). A senha fica em `/opt/britto/RESUMO.txt`. Se não instalou na hora, rode `britto-wizard mcp`.

Envio de mensagens vem **desligado** por segurança (`MCP_DISABLED_TOOLS`): a IA consulta, organiza pipelines, cria notas e tarefas e vê o funil de tráfego, mas não fala com cliente sem você.

## Claude (web e desktop)
**Configurações › Conectores › Adicionar conector personalizado** › URL `https://mcp.seudominio/mcp` › Conectar › digite a senha do conector.

## Claude Code
```bash
claude mcp add --transport http --scope user crm https://mcp.seudominio/mcp
```
Na primeira chamada, o Claude Code abre o navegador para o login com a senha do conector. Confira com `/mcp`.

## Codex (OpenAI)
Em `~/.codex/config.toml`:
```toml
[mcp_servers.crm]
url = "https://mcp.seudominio/mcp"
```
Rode `codex mcp login crm` (ou use o conector no ChatGPT, em Configurações › Conectores) e entre com a senha.

## MCPs das fontes de tráfego (opcionais, no seu computador)
- **Meta Ads:** conector oficial do Meta no Claude, em Configurações › Conectores. Faz o login com a conta que administra a conta de anúncios.
- **Google Ads:** MCP oficial `google-ads-mcp`. Ele exige um projeto no Google Cloud com acesso Explorer à API, e a aprovação pode ser negada para projetos novos. Sem ele, o painel `/trafego` continua funcionando pelo script e pela planilha (guia 08).
