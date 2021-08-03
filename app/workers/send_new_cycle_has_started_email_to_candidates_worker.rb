class SendNewCycleHasStartedEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    if CycleTimetable.send_new_cycle_has_started_email?
      GetUnsuccessfulAndUnsubmittedApplicationsFromPreviousCycle
        .call
        .find_each(batch_size: 100) { |application| SendNewCycleHasStartedEmailToCandidate.call(application_form: application) }
    end
  end
end
