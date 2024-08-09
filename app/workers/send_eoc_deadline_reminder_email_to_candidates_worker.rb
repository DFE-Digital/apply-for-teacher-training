class SendEocDeadlineReminderEmailToCandidatesWorker
  include Sidekiq::Worker

  BATCH_SIZE = 120

  def perform
    return if chaser_type.blank?

    BatchDelivery.new(
      relation: GetApplicationsToSendDeadlineRemindersTo.call,
      batch_size: BATCH_SIZE,
    ).each do |batch_time, records|
      SendEocDeadlineReminderEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
        chaser_type,
      )
    end
  end

private

  def chaser_type
    if CycleTimetable.send_first_end_of_cycle_reminder_to_candidates?
      :eoc_first_deadline_reminder
    elsif CycleTimetable.send_second_end_of_cycle_reminder_to_candidates?
      :eoc_second_deadline_reminder
    end
  end
end
