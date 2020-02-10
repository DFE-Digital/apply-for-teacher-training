class BackfillProviderChasers < ActiveRecord::Migration[6.0]
  def change
    application_choices = GetApplicationFormsWaitingForProviderDecision.call
    application_choices.each { |choice| ChaserSent.create!(chased: choice, chaser_type: :provider_decision_request) }
  end
end
