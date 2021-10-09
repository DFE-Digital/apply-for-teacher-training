class SendNewCycleHasStartedEmailToCandidatesWorker
  include Sidekiq::Worker

  STAGGER_OVER = 5.hours
  BATCH_SIZE = 120

  def perform
    if CycleTimetable.send_new_cycle_has_started_email?
      next_batch_time = Time.zone.now

      GetUnsuccessfulAndUnsubmittedCandidates
        .call
        .find_in_batches(batch_size: BATCH_SIZE) do |candidates|
          SendNewCycleHasStartedEmailToCandidatesBatchWorker.perform_at(
            next_batch_time,
            candidates.pluck(:id),
          )
          next_batch_time += interval_between_batches
        end
    end
  end

private

  def interval_between_batches
    @interval_between_batches ||= begin
      number_of_batches = (GetUnsuccessfulAndUnsubmittedCandidates.call.count.to_f / BATCH_SIZE).ceil
      number_of_batches < 2 ? STAGGER_OVER : STAGGER_OVER/((number_of_batches - 1).to_f)
    end
  end
end
