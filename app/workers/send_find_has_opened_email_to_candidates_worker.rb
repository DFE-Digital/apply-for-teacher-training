class SendFindHasOpenedEmailToCandidatesWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  BATCH_SIZE = 120

  def perform
    return unless EndOfCycle::CandidateEmailTimetabler.new.send_find_has_opened_email?

    BatchDelivery.new(relation: GetUnsuccessfulAndUnsubmittedCandidates.call, stagger_over: 12.hours, batch_size: BATCH_SIZE).each do |batch_time, records|
      SendFindHasOpenedEmailToCandidatesBatchWorker
        .set(wait_until: batch_time)
        .perform_later(records.pluck(:id))
    end
  end
end
