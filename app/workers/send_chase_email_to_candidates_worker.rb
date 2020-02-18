class SendChaseEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    return unless FeatureFlag.active?('automated_decline_by_default_candidate_chaser')

    GetApplicationFormsForDeclineByDefaultReminder.call.each do |application|
      SendChaseEmailToCandidate.call(application_form: application)
    end
  end
end
