class GetApplicationsToSendDeadlineRemindersTo
  def self.call
    if CycleTimetable.need_to_send_deadline_reminder? == :apply_1
      ApplicationForm
      .joins(:candidate)
      .where(submitted_at: nil, phase: 'apply_1', recruitment_cycle_year: RecruitmentCycle.current_year)
      .where.not(candidate: { unsubscribed_from_emails: true })
    elsif CycleTimetable.need_to_send_deadline_reminder? == :apply_2
      ApplicationForm
      .joins(:candidate)
      .where(submitted_at: nil, phase: 'apply_2', recruitment_cycle_year: RecruitmentCycle.current_year)
      .where.not(candidate: { unsubscribed_from_emails: true })
    end
  end
end
