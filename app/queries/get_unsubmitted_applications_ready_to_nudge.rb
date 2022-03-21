class GetUnsubmittedApplicationsReadyToNudge
  def call
    ApplicationForm
      .where(submitted_at: nil)
      .where('updated_at < ?', 7.days.ago)
      .where(recruitment_cycle_year: RecruitmentCycle.current_year)
  end
end
