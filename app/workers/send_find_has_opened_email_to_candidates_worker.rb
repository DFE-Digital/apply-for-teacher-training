class SendFindHasOpenedEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    if CycleTimetable.send_find_has_opened_email?
      GetUnsuccessfulAndUnsubmittedCandidates
        .call
        .find_each(batch_size: 100) { |candidate| SendFindHasOpenedEmailToCandidate.call(application_form: candidate.current_application) }
    end
  end
end
