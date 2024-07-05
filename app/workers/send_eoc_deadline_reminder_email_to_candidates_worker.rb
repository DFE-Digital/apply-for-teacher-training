class SendEocDeadlineReminderEmailToCandidatesWorker
  include Sidekiq::Worker

  BATCH_SIZE = 120

  def perform
    return unless CycleTimetable.need_to_send_deadline_reminder?

    BatchDelivery.new(
      relation: GetApplicationsToSendDeadlineRemindersTo.call,
      batch_size: BATCH_SIZE,
    ).each do |batch_time, records|
      SendEocDeadlineReminderEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
      )
    end
  end
end
