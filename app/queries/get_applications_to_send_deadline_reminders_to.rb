class GetApplicationsToSendDeadlineRemindersTo
  def self.call
    deadline_reminder_query if need_to_send_deadline_reminder?
  end

  def self.deadline_reminder_query
    ApplicationForm
      .joins(:candidate)
      .current_cycle
      .unsubmitted
      # Filter out candidates who should not be receiving emails about their accounts
      .where(candidates: { submission_blocked: false, account_locked: false, unsubscribed_from_emails: false })
  end

  def self.need_to_send_deadline_reminder?
    EmailTimetable.send_first_end_of_cycle_reminder_to_candidates? ||
      EmailTimetable.send_second_end_of_cycle_reminder_to_candidates?
  end
end
