class GetApplicationsToSendDeadlineRemindersTo
  def self.call
    deadline_reminder_query if need_to_send_deadline_reminder?
  end

  def self.deadline_reminder_query
    ApplicationForm
      .joins(:candidate).merge(Candidate.for_marketing_or_nudge_emails)
      .current_cycle
      .unsubmitted
  end

  def self.need_to_send_deadline_reminder?
    EmailTimetable.send_first_end_of_cycle_reminder_to_candidates? ||
      EmailTimetable.send_second_end_of_cycle_reminder_to_candidates?
  end
end
