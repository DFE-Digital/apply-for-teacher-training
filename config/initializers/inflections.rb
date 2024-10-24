# Be sure to restart your server when you modify this file.
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym("DfE")
  inflect.acronym("API")
  inflect.acronym("UCAS")
  inflect.acronym("TAD")
  inflect.acronym("CSV")
  inflect.acronym("QA")
  inflect.acronym("JSON")
  inflect.irregular "chaser_sent", "chasers_sent"
  inflect.irregular "provider_permissions", "provider_permissions"
  inflect.irregular "has", "have"
  inflect.irregular "was", "were"
  inflect.irregular "is", "are"
end
