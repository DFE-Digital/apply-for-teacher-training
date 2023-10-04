class GetUnsuccessfulAndUnsubmittedCandidates
  def self.call
    Candidate
      .left_outer_joins(:application_forms)
      .where.not(candidates: { unsubscribed_from_emails: true })
      .where.not(candidates: { submission_blocked: true })
      .where.not(candidates: { account_locked: true })
      .where(
        '(application_forms.recruitment_cycle_year = 2023 AND NOT EXISTS (:successful))',
        successful: ApplicationChoice
            .select(1)
            .where(status: %w[recruited pending_conditions offer offer_deferred])
            .where('application_choices.application_form_id = application_forms.id'),
      )
      .or(
        Candidate
          .where(application_forms: { recruitment_cycle_year: 2024 })
          .where.not(candidates: { unsubscribed_from_emails: true })
          .where.not(candidates: { submission_blocked: true })
          .where.not(candidates: { account_locked: true }),
      )
      .distinct
  end
end
