class GetUnsuccessfulAndUnsubmittedCandidates
  def self.call
    Candidate
      .left_outer_joins(:application_forms)
      .left_outer_joins(application_forms: :application_choices)
      .where(application_forms: { recruitment_cycle_year: 2023 })
      .where(application_choices: {
        status: %w[withdrawn cancelled rejected declined conditions_not_met offer_withdrawn application_not_sent unsubmitted],
      })
      .where.not(candidates: { unsubscribed_from_emails: true })
      .where.not(candidates: { submission_blocked: true })
      .where.not(candidates: { account_locked: true })
      .or(
        Candidate
          .where(application_forms: { submitted_at: nil, recruitment_cycle_year: 2023 })
          .where.not(candidates: { unsubscribed_from_emails: true })
          .where.not(candidates: { submission_blocked: true })
          .where.not(candidates: { account_locked: true }),
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
