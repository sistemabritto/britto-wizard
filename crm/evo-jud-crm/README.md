# evo-jud-crm no britto-wizard (em construção)

Stacks geradas da produção de referência (05/11/2026) e sanitizadas, com imagens fixadas por digest em `images.env`.
Testado em Ubuntu 24.04, Intel Xeon E3 v2 (Ivy Bridge, **sem AVX2**). Por isso o ClickHouse fica na 26.3 LTS: a 26.5+ exige AVX2.

| Stack | Arquivo | Serviços |
|---|---|---|
| traefik | `../../infra/traefik-portainer.yaml` | Traefik, Portainer, agente (comum a todos os CRMs) |
| pgvector | `stacks/pgvector.yaml` | banco do CRM (`evocrm`, `evo_campaign`) |
| postgres | `stacks/postgres.yaml` | banco do WhatsApp (`evolution_go_auth`, `evolution_go_users`) |
| evocrm | `stacks/evocrm.yaml` | gateway, auth, crm (evo-jud-crm-api), sidekiqs, core, processor (+ patch de áudio), bot runtime, frontend (evo-jud-crm), redis, clickhouse, rabbitmq, evoflow |
| evolution_go | `stacks/evolution-go.yaml` | evogo-jud |
| evocrm_mcp | `stacks/evocrm-mcp.yaml` | conector MCP (Claude, ChatGPT/Codex) |
| docuseal | `stacks/docuseal.yaml` | assinatura eletrônica (opcional) |

- `env.example`: todas as variáveis; os segredos `__GERAR_*__` são gerados pelo wizard.
- `templates/juridico.rb`: configuração inicial jurídica (3 pipelines, etiquetas, campos, macros, automação de opt-out e funil de tráfego). É idempotente e tem `BRITTO_DRY_RUN=1`. Foi validado num CRM real em transação desfeita.
- `processor-patch/sitecustomize.py`: áudio e anexos sem legenda nos agentes (ADK 1.19 + LiteLLM 1.68).
