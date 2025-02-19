class Pool::Candidates
  attr_reader :providers

  def initialize(providers:)
    @providers = providers
  end

  def self.for_provider(providers:)
    new(providers:).for_provider
  end

  def for_provider
    dismissed_candidates = Candidate.joins(:pool_dismissals).where(pool_dismissals: { provider: providers })

    Candidate
      .where(id: rejected_candidates_this_cycle)
      .pool_status_opt_in
      .excluding(dismissed_candidates)
      .joins(:application_forms)
        .where(application_forms: { recruitment_cycle_year: RecruitmentCycleTimetable.current_year })
      .select('candidates.*', 'application_forms.submitted_at')
  end

private

  def rejected_candidates_this_cycle
    curated_application_forms.select(:candidate_id)
  end

  def curated_application_forms
    ApplicationForm.current_cycle.joins(:application_choices)
      .where(application_choices: {
        status: %i[rejected declined withdrawn conditions_not_met offer_withdrawn inactive],
      })
      .where.not(
        id: ApplicationForm.joins(:application_choices).where(
          application_choices: {
            status: %i[awaiting_provider_decision interviewing offer pending_conditions recruited offer_deferred],
          },
        ).select(:id),
      )
  end
end
