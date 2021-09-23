class SendNewCycleHasStartedEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    if CycleTimetable.send_new_cycle_has_started_email?
      GetUnsuccessfulAndUnsubmittedCandidates
        .call
        .find_each(batch_size: 100) { |candidate| SendNewCycleHasStartedEmailToCandidate.call(application_form: candidate.current_application) }
    end
  end
end
