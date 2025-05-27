class Pool::Candidates
  attr_reader :filters

  def initialize(filters: {})
    @filters = filters
  end

  def self.application_forms_for_provider(filters: {})
    new(filters:).application_forms_for_provider
  end

  def application_forms_for_provider
    filtered_application_forms.joins(:candidate)
      .order(order_by)
      .distinct
  end

  def application_forms_in_the_pool
    opted_in_candidates = Candidate.joins(:published_preferences).where(published_preferences: { pool_status: 'opt_in' }).select(:id)

    curated_application_forms.joins(:candidate)
      .where(candidate: { submission_blocked: false, account_locked: false })
      .where(candidate: opted_in_candidates)
      .distinct
  end

private

  def filtered_application_forms
    scope = CandidatePoolApplication.filtered_application_forms(filters)
    filter_by_distance(scope)
  end

  def curated_application_forms
    current_cycle_forms = ApplicationForm.current_cycle

    # Subquery: To exclude forms with live applications (eg, being considered by the provider, or recruited / deferred)
    forms_with_live_applications = current_cycle_forms
                   .joins(:application_choices)
                   .where(application_choices: {
                     status: %i[awaiting_provider_decision interviewing offer pending_conditions recruited offer_deferred],
                   })

    # Subquery: To exclude forms where the candidates has withdrawn from a course because they do not want to train
    forms_that_have_been_withdrawn_for_not_wanting_to_train = current_cycle_forms
                             .joins(application_choices: :withdrawal_reasons)
                             .where('withdrawal_reasons.reason ILIKE ?', '%do-not-want-to-train-anymore%')

    # Subquery: To include only those forms who have not used all their application slows
    forms_with_available_slots = current_cycle_forms
                         .joins(:application_choices)
                         .where(application_choices: {
                           status: ApplicationStateChange::UNSUCCESSFUL_STATES,
                         })
                         .group(:id)
                         .having("count(CASE WHEN application_choices.status != 'inactive' THEN 1 END) < ?", ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS)
                         .select(:id)

    # Final query
    current_cycle_forms
      .joins(:application_choices)
      .where(application_choices: {
        status: %i[rejected declined withdrawn conditions_not_met offer_withdrawn inactive],
      })
      .where(id: forms_with_available_slots)
      .where.not(id: forms_with_live_applications.select('application_forms.id'))
      .where.not(id: forms_that_have_been_withdrawn_for_not_wanting_to_train.select('application_forms.id'))
  end

  def filter_by_distance(application_forms_scope)
    return application_forms_scope unless active_location_filter?

    origin = filters.fetch(:origin)

    candidate_preferences_anywhere = CandidatePreference.where(pool_status: 'opt_in', status: 'published')
                                       .where.missing(:location_preferences)
                                       .select('candidate_preferences.candidate_id as candidate_id', '-1 as distance')

    candidate_location_preferences_near_origin = CandidateLocationPreference
                                                   .joins(:candidate_preference)
                                                   .where(candidate_preferences: { pool_status: 'opt_in', status: 'published' })
                                                   .near(origin, :within)
                                                   .select('candidate_preferences.candidate_id as candidate_id')

    candidates_near_origin = Candidate.with(
      candidate_preferences_anywhere: candidate_preferences_anywhere,
      candidate_location_preferences_near_origin: candidate_location_preferences_near_origin,
    )
                               .joins('LEFT OUTER JOIN candidate_preferences_anywhere ON candidate_preferences_anywhere.candidate_id = candidates.id')
                               .joins('LEFT OUTER JOIN candidate_location_preferences_near_origin ON candidate_location_preferences_near_origin.candidate_id = candidates.id')
                               .where('candidate_preferences_anywhere.distance IS NOT NULL OR candidate_location_preferences_near_origin.distance IS NOT NULL')
                               .select('candidates.*', 'MIN(COALESCE(candidate_preferences_anywhere.distance, candidate_location_preferences_near_origin.distance)) as distance')
                                      .group('candidates.id')

    application_forms_scope.with(candidates_near_origin: candidates_near_origin)
                           .joins('INNER JOIN candidates_near_origin ON candidates_near_origin.id = application_forms.candidate_id')
                           .select('application_forms.*', 'candidates_near_origin.distance as site_distance')
  end

  def active_location_filter?
    filters[:origin].present?
  end

  def order_by
    if active_location_filter?
      'site_distance ASC'
    else
      'application_forms.submitted_at'
    end
  end
end
