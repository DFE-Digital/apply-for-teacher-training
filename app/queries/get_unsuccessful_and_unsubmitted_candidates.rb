class GetUnsuccessfulAndUnsubmittedCandidates
  def self.call
    Candidate
    .joins(:application_forms)
    .where(
      application_forms: { recruitment_cycle_year: RecruitmentCycle.previous_year, id: ApplicationChoice.where(status: ApplicationStateChange::UNSUCCESSFUL_END_STATES).select(:application_form_id) },
    )
    .where.not(
      application_forms:
      {
        id: ApplicationChoice.where(status: ApplicationStateChange::SUCCESSFUL_STATES)
        .select(:application_form_id),
      },
    )
    .or(Candidate.joins(:application_forms).where(application_forms: { submitted_at: nil, recruitment_cycle_year: RecruitmentCycle.previous_year }))
    .or(Candidate.joins(:application_forms).where(application_forms: { recruitment_cycle_year: RecruitmentCycle.current_year }))
    .includes(:application_choices)
    .distinct
  end
end
