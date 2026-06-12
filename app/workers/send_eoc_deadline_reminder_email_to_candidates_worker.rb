class SendEocDeadlineReminderEmailToCandidatesWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  BATCH_SIZE = 120

  def perform
    return if chaser_type.blank?

    BatchDelivery.new(
      relation: GetApplicationsToSendDeadlineRemindersTo.call,
      batch_size: BATCH_SIZE,
    ).each do |batch_time, records|
      SendEocDeadlineReminderEmailToCandidatesBatchWorker
        .set(wait_until: batch_time)
        .perform_later(records.pluck(:id), chaser_type)
    end
  end

private

  def chaser_type
    if email_timetabler.send_first_end_of_cycle_reminder?
      'eoc_first_deadline_reminder'
    elsif email_timetabler.send_second_end_of_cycle_reminder?
      'eoc_second_deadline_reminder'
    end
  end

  def email_timetabler
    @email_timetabler ||= EndOfCycle::CandidateEmailTimetabler.new
  end
end
