class GetApplicationsToSendDeadlineRemindersTo
  def self.call
    deadline_reminder_query if CycleTimetable.need_to_send_deadline_reminder?
  end

  def self.deadline_reminder_query
    ApplicationForm
    .includes(:candidate)
    .current_cycle
    .unsubmitted
    .where.not(candidate: { unsubscribed_from_emails: true })
    .where.not(candidate: { submission_blocked: true })
    .where.not(candidate: { account_locked: true })
  end
end
