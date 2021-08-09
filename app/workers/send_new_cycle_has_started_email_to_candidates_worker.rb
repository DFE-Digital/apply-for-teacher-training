class SendNewCycleHasStartedEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    if CycleTimetable.send_new_cycle_has_started_email?
      GetUnsuccessfulAndUnsubmittedApplicationsFromPreviousCycle
        .call
        .find_each(batch_size: 100) do |application|
          SendNewCycleHasStartedEmailToCandidate.call(application_form: application)
          sleep 0.03
        end
    end
  end
end
