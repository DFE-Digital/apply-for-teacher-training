class SendNewCycleHasStartedEmailToCandidatesWorker
  include Sidekiq::Worker

  STAGGER_OVER = 5.hours
  BATCH_SIZE = 120

  def perform
    if CycleTimetable.send_new_cycle_has_started_email?
      next_batch_time = Time.zone.now

      recipients.find_in_batches(batch_size: BATCH_SIZE) do |candidates|
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
      number_of_batches = (recipients.count.to_f / BATCH_SIZE).ceil
      number_of_batches < 2 ? STAGGER_OVER : STAGGER_OVER / (number_of_batches - 1).to_f
    end
  end

  def recipients
    GetUnsuccessfulAndUnsubmittedCandidates.call.where(
      "NOT EXISTS (
        SELECT recipient_application_forms.candidate_id
        FROM application_forms as recipient_application_forms
        JOIN chasers_sent ON application_forms.id = chasers_sent.chased_id AND chasers_sent.chased_type = 'ApplicationForm'
        WHERE chasers_sent.chaser_type = 'new_cycle_has_started' AND chasers_sent.created_at > ?
      )",
      CycleTimetable.apply_opens,
    )
  end
end
