# britto-wizard · template "juridico" para o evo-jud-crm.
# Roda dentro do container do CRM:  bundle exec rails runner /tmp/template.rb
# Idempotente: procura pelo nome antes de criar; nada é apagado nem sobrescrito.
# Parâmetros por variável de ambiente (o wizard passa):
#   BRITTO_ORG_NAME, BRITTO_WHATSAPP (só dígitos, com DDI), BRITTO_SCHEDULING_URLS (vírgula),
#   BRITTO_DRY_RUN=1 (cria tudo numa transação e desfaz no fim: só valida).

ORG = ENV.fetch('BRITTO_ORG_NAME', 'Escritório').strip
WHATSAPP = ENV.fetch('BRITTO_WHATSAPP', '').gsub(/\D/, '')
SCHEDULING = ENV.fetch('BRITTO_SCHEDULING_URLS', '').strip
DRY = ENV['BRITTO_DRY_RUN'] == '1'

author = User.where(type: 'SuperAdmin').order(:created_at).first || User.order(:created_at).first
abort('Crie a primeira conta no CRM antes de aplicar o template.') unless author

PIPELINES = [
  {
    name: 'Comercial',
    description: 'Do primeiro contato ao contrato assinado (aquisição).',
    stages: [
      ['Novo contato', '#94A3B8', :active, 'Entrou pelo WhatsApp, site ou redes; a IA iniciou o atendimento'],
      ['Triagem em andamento', '#60A5FA', :active, 'Aceite LGPD e coleta dos dados mínimos'],
      ['Pré-qualificado', '#3B82F6', :active, 'Assunto dentro das áreas atendidas e dados mínimos completos'],
      ['Documentação pendente', '#F59E0B', :active, 'Aguardando documentos do checklist'],
      ['Reunião agendada', '#8B5CF6', :active, 'Data marcada com o advogado'],
      ['Consulta realizada', '#7C3AED', :active, 'Advogado analisou o caso'],
      ['Proposta de honorários', '#EC4899', :active, 'Proposta elaborada ou enviada'],
      ['Contrato enviado', '#F97316', :active, 'Contrato enviado para assinatura eletrônica'],
      ['Contratado', '#10B981', :completed, 'Contrato assinado e pagamento confirmado'],
      ['Não fechou', '#9CA3AF', :cancelled, 'Desistiu, sem retorno ou fora do escopo']
    ]
  },
  {
    name: 'Pós-venda e processos',
    description: 'Clientes contratados: onboarding, andamento do caso e encerramento.',
    stages: [
      ['Novo cliente', '#94A3B8', :active, 'Veio do Comercial ou chegou pelo canal de suporte'],
      ['Onboarding e documentos', '#60A5FA', :active, 'Coleta de documentos e dados para iniciar'],
      ['Em andamento', '#3B82F6', :active, 'Caso em execução'],
      ['Audiência/perícia marcada', '#8B5CF6', :active, 'Audiência, perícia ou avaliação designada'],
      ['Decisão/sentença', '#EC4899', :active, 'Decisão relevante publicada'],
      ['Recurso/acórdão', '#F97316', :active, 'Recurso, acórdão ou turma recursal'],
      ['Cumprimento/execução', '#059669', :active, 'Cumprimento de sentença, RPV, precatório ou alvará'],
      ['Aguardando cliente', '#F59E0B', :active, 'Depende de retorno ou documento do cliente'],
      ['Concluído', '#10B981', :completed, 'Caso encerrado']
    ]
  },
  {
    name: 'Prazos e publicações',
    description: 'Um card por cliente, uma tarefa por publicação (monitor jurídico do conector MCP).',
    stages: [
      ['Nova', '#60A5FA', :active, ''], ['Prazo calculado', '#F59E0B', :active, ''],
      ['Em elaboração', '#A78BFA', :active, ''], ['Protocolado', '#34D399', :active, ''],
      ['Arquivado', '#9CA3AF', :active, '']
    ]
  }
].freeze

LABELS = [
  ['aguardando-retorno', 'Aguardando resposta do contato', '#FBBF24'],
  ['bot-pausado', 'Atendimento humano assumiu; a IA não responde até remover a etiqueta', '#1F93FF'],
  ['cliente-ativo', 'Já é cliente com caso em andamento; vai direto para a equipe', '#14B8A6'],
  ['documento-recebido', 'Contato enviou PDF, foto ou vídeo; o arquivo está na conversa', '#D97706'],
  ['equipe', 'Contato interno (agentes não respondem e fica fora do funil)', '#0EA5E9'],
  ['fora-do-escopo', 'Assunto fora das áreas atendidas', '#6B7280'],
  ['opt-out', 'Pediu para não receber mensagens', '#DC2626'],
  ['prioridade-humano', 'Precisa do advogado agora', '#B91C1C'],
  ['origem-meta', 'Veio de anúncio do Meta (Facebook/Instagram)', '#1877F2'],
  ['origem-google', 'Veio de anúncio do Google', '#34A853'],
  ['origem-site', 'Veio do botão de WhatsApp do site', '#0F766E'],
  ['origem-instagram', 'Veio do Instagram orgânico (bio, stories)', '#C13584'],
  ['origem-postiz', 'Veio de post publicado pelo Postiz', '#7C3AED'],
  ['origem-openreply', 'Veio de DM automática do OpenReply', '#9333EA']
].freeze

ATTRIBUTES = [
  ['Área jurídica', 'area_juridica', :list, ['Família e sucessões', 'Imobiliário', 'Previdenciário', 'Cível', 'Trabalhista',
                                            'Consumidor', 'Empresarial', 'Tributário', 'Criminal', 'Outro']],
  ['Cidade/UF', 'cidade_uf', :text, []],
  ['Urgência / prazo', 'urgencia_prazo', :text, []],
  ['Documentos pendentes', 'documentos_pendentes', :text, []],
  ['Consentimento LGPD (data/hora)', 'consentimento_lgpd', :datetime, []],
  ['Não contatar (opt-out)', 'nao_contatar', :checkbox, []],
  ['Nome completo (documentos)', 'nome_completo', :text, []],
  ['Tipo de pessoa', 'tipo_pessoa', :list, %w[PF PJ]],
  ['CPF/CNPJ', 'cpf_cnpj', :text, []],
  ['Processos (CNJ)', 'processos', :text, []]
].freeze

created = Hash.new(0)

ActiveRecord::Base.transaction do
  PIPELINES.each do |pd|
    pipeline = Pipeline.find_by(name: pd[:name])
    unless pipeline
      pipeline = Pipeline.create!(name: pd[:name], description: pd[:description], created_by_id: author.id,
                                  pipeline_type: 'custom', visibility: :public, is_active: true)
      created[:pipelines] += 1
    end
    pd[:stages].each_with_index do |(name, color, type, desc), i|
      next if pipeline.pipeline_stages.exists?(name: name)

      pipeline.pipeline_stages.create!(name: name, color: color, stage_type: type, position: i + 1,
                                       automation_rules: desc.present? ? { 'description' => desc } : {})
      created[:stages] += 1
    end
  end

  LABELS.each do |title, description, color|
    next if Label.exists?(title: title)

    Label.create!(title: title, description: description, color: color, show_on_sidebar: true)
    created[:labels] += 1
  end

  ATTRIBUTES.each do |display, key, type, values|
    next if CustomAttributeDefinition.exists?(attribute_key: key, attribute_model: :contact_attribute)

    CustomAttributeDefinition.create!(attribute_display_name: display, attribute_description: display, attribute_key: key,
                                      attribute_display_type: type, attribute_model: :contact_attribute,
                                      attribute_values: values)
    created[:attributes] += 1
  end

  label_id = ->(title) { Label.find_by(title: title)&.id }
  macros = [
    ['Documento recebido', [
      { 'action_name' => 'add_label', 'action_params' => [label_id.call('documento-recebido')] },
      { 'action_name' => 'remove_label', 'action_params' => [label_id.call('aguardando-retorno')] },
      { 'action_name' => 'add_private_note',
        'action_params' => ['Documento recebido do cliente. Conferir, salvar na pasta do caso e mover o card de etapa se for o caso.'] }
    ]],
    ['Encerrar atendimento', [
      { 'action_name' => 'send_message',
        'action_params' => ["Obrigado pelo contato! Se precisar de algo mais, é só chamar por aqui. Equipe #{ORG}."] },
      { 'action_name' => 'resolve_conversation', 'action_params' => [] }
    ]]
  ]
  macros.each do |name, actions|
    next if Macro.exists?(name: name)

    Macro.create!(name: name, visibility: :global, created_by_id: author.id, updated_by_id: author.id, actions: actions)
    created[:macros] += 1
  end

  unless AutomationRule.exists?(name: 'Opt-out · Sair/Parar')
    AutomationRule.create!(
      name: 'Opt-out · Sair/Parar',
      description: 'Contato pediu para parar: marca "não contatar" e aplica a etiqueta opt-out.',
      event_name: 'message_created', active: true, mode: 'simple',
      conditions: [
        { 'values' => ['0'], 'attribute_key' => 'message_type', 'query_operator' => 'AND', 'filter_operator' => 'equal_to' },
        { 'values' => %w[sair Sair SAIR parar Parar PARAR pare Pare stop] + ['cancelar avisos'],
          'attribute_key' => 'content', 'filter_operator' => 'equal_to' }
      ],
      actions: [
        { 'action_name' => 'update_custom_attribute',
          'action_params' => [{ 'custom_attribute_key' => 'nao_contatar', 'custom_attribute_model' => 'contact_attribute',
                                'custom_attribute_value' => 'true' }] },
        { 'action_name' => 'add_label', 'action_params' => ['opt-out'] }
      ]
    )
    created[:automations] += 1
  end

  # Funil de tráfego: quais etapas contam como reunião e contrato; número do WhatsApp; links de agenda.
  if defined?(Tracking::Config)
    stage = ->(pipe, name) { Pipeline.find_by(name: pipe)&.pipeline_stages&.find_by(name: name)&.id }
    {
      'TRACKING_STAGE_MEETING_IDS' => [stage.call('Comercial', 'Reunião agendada')],
      'TRACKING_STAGE_CONTRACT_IDS' => [stage.call('Comercial', 'Contratado'), stage.call('Pós-venda e processos', 'Novo cliente')]
    }.each do |key, ids|
      next if GlobalConfigService.load(key, nil).present?

      GlobalConfig.set(key, ids.compact.join(','))
      created[:tracking] += 1
    end
    if WHATSAPP.present? && GlobalConfigService.load('TRACKING_WHATSAPP_NUMBER', nil).blank?
      GlobalConfig.set('TRACKING_WHATSAPP_NUMBER', WHATSAPP)
      created[:tracking] += 1
    end
    if SCHEDULING.present? && GlobalConfigService.load('TRACKING_SCHEDULING_URLS', nil).blank?
      GlobalConfig.set('TRACKING_SCHEDULING_URLS', SCHEDULING)
      created[:tracking] += 1
    end
  end

  if DRY
    puts "DRY-RUN ok (nada gravado): #{created.to_h}"
    raise ActiveRecord::Rollback
  end
end

unless DRY
  GlobalConfig.clear_cache if GlobalConfig.respond_to?(:clear_cache)
  puts "Template jurídico aplicado: #{created.to_h} (itens já existentes foram mantidos)"
end
