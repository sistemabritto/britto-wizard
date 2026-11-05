#!/usr/bin/env bash
# Verificação pós-instalação (usada no GitHub Actions). Sai != 0 se algo falhar.
set -u
falhas=0
checa() { if eval "$2"; then echo "✔ $1"; else echo "✘ $1"; falhas=$((falhas + 1)); fi; }
code() { curl -sk -o /dev/null -w '%{http_code}' --max-time 20 "$@"; }

echo "== aguardando estabilizar (até 20 min)"
for i in $(seq 1 120); do
  fora=$(docker service ls --format '{{.Replicas}} {{.Name}}' | awk '{split($1,a,"/"); if (a[1]!=a[2]) print $2}')
  [ -z "$fora" ] && [ "$(code https://api-crm.teste.local/health)" = 200 ] && break; sleep 10
done
echo "== serviços"; docker service ls --format '{{.Replicas}} {{.Name}}' | sort -k2
fora=$(docker service ls --format '{{.Replicas}} {{.Name}}' | awk '{split($1,a,"/"); if (a[1]!=a[2]) print $2}')
checa "todos os serviços com réplicas completas (${fora:-nenhum fora})" '[ -z "$fora" ]'

echo "== endereços"
checa "API do CRM /health = 200" '[ "$(code https://api-crm.teste.local/health)" = 200 ]'
checa "painel do CRM = 200" '[ "$(code https://crm.teste.local/)" = 200 ]'
checa "Portainer = 200" '[ "$(code https://portainer.teste.local/)" = 200 ]'
checa "Evolution Go /server/ok = 200" '[ "$(code https://whatsapp.teste.local/server/ok)" = 200 ]'
checa "conector MCP responde e exige login (401/403)" '[[ "$(code -X POST https://mcp.teste.local/mcp)" =~ ^40[13]$ ]]'
checa "DocuSeal no ar (200/302)" '[[ "$(code https://assinatura.teste.local/)" =~ ^(200|302)$ ]]'
checa "cadastro público FECHADO (register = 403)" '[ "$(code -X POST -H "Content-Type: application/json" -d "{}" https://api-crm.teste.local/api/v1/auth/register)" = 403 ]'

echo "== dados do CRM"
C=$(docker ps -q -f name=^evocrm_evocrm_crm\\. | head -1)
cat > /tmp/v.rb <<'RB'
P = ['Comercial', 'Pós-venda e processos', 'Prazos e publicações']
L = %w[aguardando-retorno bot-pausado cliente-ativo documento-recebido equipe fora-do-escopo opt-out prioridade-humano origem-meta origem-google origem-site origem-instagram origem-postiz origem-openreply]
A = %w[area_juridica cidade_uf urgencia_prazo documentos_pendentes consentimento_lgpd nao_contatar nome_completo tipo_pessoa cpf_cnpj processos]
puts({ usuarios: User.where.not(type: 'AgentBot').count, pipelines: Pipeline.where(name: P).count,
       etapas: PipelineStage.joins(:pipeline).where(pipelines: { name: P }).count, etiquetas: Label.where(title: L).count,
       campos: CustomAttributeDefinition.where(attribute_key: A).count,
       macros: Macro.where(name: ['Documento recebido', 'Encerrar atendimento']).count,
       automacoes: AutomationRule.where(name: 'Opt-out · Sair/Parar').count,
       evolution_go_url: GlobalConfigService.load('EVOLUTION_GO_API_URL', nil).present?,
       tracking_reuniao: GlobalConfigService.load('TRACKING_STAGE_MEETING_IDS', nil).present?,
       whatsapp: GlobalConfigService.load('TRACKING_WHATSAPP_NUMBER', nil),
       cadastro: ENV['ENABLE_ACCOUNT_SIGNUP'] }.to_json)
RB
docker cp /tmp/v.rb "$C:/tmp/v.rb" >/dev/null
J=$(docker exec "$C" bundle exec rails runner /tmp/v.rb 2>/dev/null | tail -1); echo "$J"
v() { python3 -c "import json,sys;print(json.loads(sys.argv[1]).get(sys.argv[2]))" "$J" "$1"; }
checa "admin criado pelo wizard (>=1 usuário)" '[ "$(v usuarios)" -ge 1 ]'
checa "3 pipelines do template jurídico" '[ "$(v pipelines)" = 3 ]'
checa "24 etapas" '[ "$(v etapas)" = 24 ]'
checa "14 etiquetas do template" '[ "$(v etiquetas)" = 14 ]'
checa "10 campos do template" '[ "$(v campos)" = 10 ]'
checa "macros (2) e automação de opt-out (1)" '[ "$(v macros)" = 2 ] && [ "$(v automacoes)" = 1 ]'
checa "Evolution Go configurado no CRM" '[ "$(v evolution_go_url)" = True ]'
checa "funil de tráfego configurado (etapa de reunião)" '[ "$(v tracking_reuniao)" = True ]'
checa "WhatsApp do tracking gravado" '[ "$(v whatsapp)" = 5500000000000 ]'
checa "ENABLE_ACCOUNT_SIGNUP=false no CRM" '[ "$(v cadastro)" = false ]'

echo "== arquivos"
checa ".env com permissão 600" '[ "$(stat -c %a /opt/britto/.env)" = 600 ]'
checa "RESUMO com permissão 600" '[ "$(stat -c %a /opt/britto/RESUMO.txt)" = 600 ]'
checa "nenhum segredo sem gerar" '! grep -q __GERAR /opt/britto/.env'
checa "comando britto-wizard instalado" 'command -v britto-wizard >/dev/null'

echo "== resultado: $falhas falha(s)"; exit "$falhas"
