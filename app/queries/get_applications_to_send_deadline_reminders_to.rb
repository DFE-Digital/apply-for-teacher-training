class GetApplicationsToSendDeadlineRemindersTo
  def self.call
    new.call
  end

  def call
    deadline_reminder_query if send_deadline_reminder?
  end

  def deadline_reminder_query
    ApplicationForm
      .joins(:candidate).merge(Candidate.for_marketing_or_nudge_emails)
      .current_cycle
      .unsubmitted
  end

private

  def send_deadline_reminder?
    email_timetabler.send_first_end_of_cycle_reminder? ||
      email_timetabler.send_second_end_of_cycle_reminder?
  end

  def email_timetabler
    @email_timetabler ||= EndOfCycle::CandidateEmailTimetabler.new
  end
end
