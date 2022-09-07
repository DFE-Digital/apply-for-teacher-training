class GetApplicationsToSendDeadlineRemindersTo
  def self.call
    if CycleTimetable.need_to_send_deadline_reminder? == :apply_1
      deadline_reminder_candidates_apply_1
    elsif CycleTimetable.need_to_send_deadline_reminder? == :apply_2
      deadline_reminder_candidates_apply_2
    end
  end

  def self.deadline_reminder_candidates_apply_1
    deadline_reminder_query(phase: 'apply_1')
  end

  def self.deadline_reminder_candidates_apply_2
    deadline_reminder_query(phase: 'apply_2')
  end

  def self.deadline_reminder_query(phase:)
    ApplicationForm
    .joins(:candidate)
    .where(submitted_at: nil, phase:, recruitment_cycle_year: RecruitmentCycle.current_year)
    .where.not(candidate: { unsubscribed_from_emails: true })
  end
end
