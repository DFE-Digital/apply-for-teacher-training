class CandidateMailers::SendDeclinedLastApplicationChoiceEmailWorker
  include Sidekiq::Worker

  def perform(application_choice_id)
    application_choice = ApplicationChoice.find(application_choice_id)

    CandidateMailer.decline_last_application_choice(application_choice).deliver_later
  end
end
