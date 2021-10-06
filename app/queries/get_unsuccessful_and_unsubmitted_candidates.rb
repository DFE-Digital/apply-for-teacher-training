class GetUnsuccessfulAndUnsubmittedCandidates
  def self.call
    Candidate
    .joins(:application_forms)
    .where(
      application_forms: {
        recruitment_cycle_year: RecruitmentCycle.previous_year,
        id: ApplicationChoice.where(status: ApplicationStateChange::UNSUCCESSFUL_END_STATES).select(:application_form_id),
      },
    )
    .where.not(
      application_forms:
      {
        id: ApplicationChoice.where(status: ApplicationStateChange::SUCCESSFUL_STATES)
        .select(:application_form_id),
      },
    )
    .where.not(unsubscribed_from_emails: true)
    .or(
      Candidate.joins(:application_forms)
      .where(application_forms:
        {
          submitted_at: nil,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
        })
      .where.not(unsubscribed_from_emails: true),
    )
    .or(
      Candidate
      .joins(:application_forms)
      .where(application_forms:
        {
          recruitment_cycle_year:
          RecruitmentCycle.current_year,
        })
      .where.not(unsubscribed_from_emails: true),
    )
    .includes(:application_choices)
    .distinct
  end
end
