ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym('DfE')
  inflect.acronym('API')
  inflect.acronym('UCAS')
  inflect.irregular 'chaser_sent', 'chasers_sent'
  inflect.irregular 'provider_permissions', 'provider_permissions'
end
