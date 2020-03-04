class SendChaseEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    GetApplicationFormsForDeclineByDefaultReminder.call.each do |application|
      SendChaseEmailToCandidate.call(application_form: application)
    end
  end
end
