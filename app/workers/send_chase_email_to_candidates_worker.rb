class SendChaseEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    return unless FeatureFlag.active?('automated_candidate_chaser')

    GetApplicationChoicesWaitingForCandidateDecision.call.each do |application|
      SendChaseEmailToCandidate.call(application_form: application)
    end
  end
end
