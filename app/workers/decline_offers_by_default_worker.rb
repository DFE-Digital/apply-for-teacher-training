class DeclineOffersByDefaultWorker
  include Sidekiq::Worker

  def perform
    GetApplicationFormsReadyToDeclineByDefault.call.each do |application_form|
      DeclineOfferByDefault.new(application_form: application_form).call
    end
  end
end
