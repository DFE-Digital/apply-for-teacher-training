class DeclineOffersByDefaultWorker
  include Sidekiq::Worker

  def perform
    GetApplicationFormsReadyToDeclineByDefault.call.each do |application_form|
      application_form.application_choices.offer.each do |application_choice_with_offer|
        DeclineOfferByDefault.new(application_choice: application_choice_with_offer).call
      end
    end
  end
end
