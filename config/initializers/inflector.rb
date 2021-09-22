ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym('DfE')
  inflect.acronym('API')
  inflect.acronym('UCAS')
  inflect.acronym('TAD')
  inflect.acronym('CSV')
  inflect.acronym('QA')
  inflect.irregular 'chaser_sent', 'chasers_sent'
  inflect.irregular 'provider_permissions', 'provider_permissions'
  inflect.irregular 'has', 'have'
  inflect.irregular 'was', 'were'
end
