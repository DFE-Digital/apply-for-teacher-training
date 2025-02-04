class SendFindHasOpenedEmailToCandidatesWorker
  include Sidekiq::Worker

  BATCH_SIZE = 120

  def perform
    return unless EndOfCycle::CandidateEmailTimetabler.new.send_find_has_opened_email?

    BatchDelivery.new(relation: GetUnsuccessfulAndUnsubmittedCandidates.call, stagger_over: 12.hours, batch_size: BATCH_SIZE).each do |batch_time, records|
      SendFindHasOpenedEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
      )
    end
  end
end
