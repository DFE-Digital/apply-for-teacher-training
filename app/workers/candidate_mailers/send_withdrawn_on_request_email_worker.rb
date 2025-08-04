class CandidateMailers::SendWithdrawnOnRequestEmailWorker
  include Sidekiq::Worker

  def perform(application_choice_id)
    application_choice = ApplicationChoice.find(application_choice_id)

    CandidateMailer.application_withdrawn_on_request(application_choice).deliver_later
  end
end
