class SendCandidateRejectionEmailWorker
  include Sidekiq::Worker
  include SafePerformAsync

  def perform(application_choice_id)
    SendCandidateRejectionEmail.new(
      application_choice: ApplicationChoice.find(application_choice_id),
    ).call
  end
end
