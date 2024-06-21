class SendNewCycleHasStartedEmailToCandidatesWorker
  include Sidekiq::Worker

  BATCH_SIZE = 120

  def perform
    return unless CycleTimetable.send_new_cycle_has_started_email?

    BatchDelivery.new(
      relation: GetUnsuccessfulAndUnsubmittedCandidates.call,
      stagger_over: 12.hours,
      batch_size: BATCH_SIZE,
    ).each do |batch_time, records|
      SendNewCycleHasStartedEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
      )
    end
  end
end
