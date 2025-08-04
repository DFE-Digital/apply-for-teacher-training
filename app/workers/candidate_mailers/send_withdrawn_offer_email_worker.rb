class CandidateMailers::SendWithdrawnOfferEmailWorker
  include Sidekiq::Worker

  def perform(application_choice_id)
    application_choice = ApplicationChoice.find(application_choice_id)

    CandidateMailer.offer_withdrawn(application_choice).deliver_later
  end
end
