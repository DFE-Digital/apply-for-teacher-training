class SendChaseEmailToCandidatesWorker
  include Sidekiq::Worker
  include SafePerformAsync

  def perform
    GetApplicationFormsForDeclineByDefaultReminder.call.each do |application|
      SendChaseEmailToCandidate.call(application_form: application)
    end
  end
end
