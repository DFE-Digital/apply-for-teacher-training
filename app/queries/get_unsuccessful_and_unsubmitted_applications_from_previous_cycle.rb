class GetUnsuccessfulAndUnsubmittedApplicationsFromPreviousCycle
  def self.call
    ApplicationForm
      .where(
        recruitment_cycle_year: RecruitmentCycle.previous_year,
        application_forms: { id: ApplicationChoice.where(status: ApplicationStateChange::UNSUCCESSFUL_END_STATES).select(:application_form_id) },
      )
      .or(ApplicationForm.where(submitted_at: nil, recruitment_cycle_year: RecruitmentCycle.previous_year))
      .includes(:application_choices)
      .distinct
  end
end
