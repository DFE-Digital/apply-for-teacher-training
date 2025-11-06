class ApplicationChoicesVisaSponsorshipDeadlineReminder
  def self.call
    new.call
  end

  def call
    ApplicationChoice
      .joins(:application_form).merge(ApplicationForm.requires_visa_sponsorship)
      .joins(:candidate).merge(Candidate.for_marketing_or_nudge_emails)
      .joins(:current_course)
      .left_outer_joins(:chasers_sent)
      .where(
        "chasers_sent.course_code IS NULL OR
          chasers_sent.course_code != courses.code AND chaser_type = 'visa_sponsorship_deadline'",
      )
      .where('courses.visa_sponsorship_application_deadline_at <= ?', 1.month.from_now)
      .where(
        status: 'unsubmitted',
        current_recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
      )
      .distinct
  end
end
