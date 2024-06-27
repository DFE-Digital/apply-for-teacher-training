class GetApplicationsToSendDeadlineRemindersTo
  def self.call
    deadline_reminder_query if CycleTimetable.need_to_send_deadline_reminder?
  end

  def self.deadline_reminder_query
    ApplicationForm
    .joins(:candidate)
    .where(submitted_at: nil, recruitment_cycle_year: RecruitmentCycle.current_year)
    .where.not(candidate: { unsubscribed_from_emails: true })
  end
end
