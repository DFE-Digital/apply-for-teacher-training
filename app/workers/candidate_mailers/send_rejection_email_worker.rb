class CandidateMailers::SendRejectionEmailWorker
  include Sidekiq::Worker

  def perform(application_choice_id)
    application_choice = ApplicationChoice.find(application_choice_id)

    CandidateMailer.application_rejected(application_choice).deliver_later
  end
end
