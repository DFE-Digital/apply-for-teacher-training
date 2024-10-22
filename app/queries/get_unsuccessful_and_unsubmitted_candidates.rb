class GetUnsuccessfulAndUnsubmittedCandidates
  def self.call
    previous_recruitment_year = RecruitmentCycle.previous_year
    # Candidates who didn't have successful applications last year
    Candidate
      .left_outer_joins(:application_forms)
      .for_marketing_or_nudge_emails
      .where(
        '(application_forms.recruitment_cycle_year = (:previous_recruitment_year) AND NOT EXISTS (:successful))',
        previous_recruitment_year:,
        successful: ApplicationChoice
            .select(1)
            .where(status: ApplicationStateChange::SUCCESSFUL_STATES)
            .where('application_choices.application_form_id = application_forms.id'),
      )
      .or(
        # Candidates who have started working on applications this year, but not submitted.
        Candidate
          .for_marketing_or_nudge_emails
          .where(application_forms: {
            recruitment_cycle_year: RecruitmentCycle.current_year,
            submitted_at: nil,
          }),
      )
      .distinct
  end
end
