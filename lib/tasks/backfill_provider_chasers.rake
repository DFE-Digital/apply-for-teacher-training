desc 'Markes all application choices as chased that had to be chased by the date'
task backfill_provider_chasers: :environment do
  application_choices = GetApplicationFormsWaitingForProviderDecision.call
  application_choices.each { |choice| ChaserSent.create!(chased: choice, chaser_type: :provider_decision_request) }
end
