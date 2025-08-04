class CandidateMailers::SendWithdrawnLastApplicationChoiceEmailWorker
  include Sidekiq::Worker

  def perform(application_form_id)
    application_form = ApplicationForm.find(application_form_id)

    CandidateMailer.withdraw_last_application_choice(application_form).deliver_later
  end
end
