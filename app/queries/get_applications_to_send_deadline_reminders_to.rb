class GetApplicationsToSendDeadlineRemindersTo
  def self.call
    deadline_reminder_query if CycleTimetable.need_to_send_deadline_reminder?
  end

  def self.deadline_reminder_query
    ApplicationForm
    .joins(:candidate)
    .current_cycle
    .unsubmitted
    # Filter out candidates who should not be receiving emails about their accounts
    .where(candidates: { submission_blocked: false, account_locked: false, unsubscribed_from_emails: false })
  end
end
