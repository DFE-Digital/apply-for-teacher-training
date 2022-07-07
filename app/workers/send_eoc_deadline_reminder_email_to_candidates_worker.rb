class SendEocDeadlineReminderEmailToCandidatesWorker
  include Sidekiq::Worker

  STAGGER_OVER = 5.hours
  BATCH_SIZE = 120

  def perform
    return unless CycleTimetable.need_to_send_deadline_reminder?

    next_batch_time = Time.zone.now

    GetApplicationsToSendDeadlineRemindersTo.call.find_in_batches(batch_size: BATCH_SIZE) do |applications|
      SendEocDeadlineReminderEmailToCandidatesBatchWorker.perform_at(
        next_batch_time,
        applications.pluck(:id),
      )

      next_batch_time += interval_between_batches
    end
  end

private

  def interval_between_batches
    @interval_between_batches ||= begin
      number_of_batches = (GetApplicationsToSendDeadlineRemindersTo.call.count.to_f / BATCH_SIZE).ceil
      number_of_batches < 2 ? STAGGER_OVER : STAGGER_OVER / (number_of_batches - 1).to_f
    end
  end
end
