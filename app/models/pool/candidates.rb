class Pool::Candidates
  attr_reader :providers, :filters

  def initialize(providers:, filters: {})
    @providers = providers
    @filters = filters
  end

  def self.application_forms_for_provider(providers:, filters: {})
    new(providers:, filters:).application_forms_for_provider
  end

  def application_forms_for_provider
    # can this not be a join?
    # Why do we return duplicate application_forms?
    # Can we return only the columns we need?
    opted_in_candidates = Candidate.joins(:published_preferences).where(published_preferences: { pool_status: 'opt_in' }).select(:id)
    dismissed_candidates = Candidate.joins(:pool_dismissals).where(pool_dismissals: { provider: providers }).select(:id)

    results = filtered_application_forms.joins(:candidate)
      .where(candidate: { submission_blocked: false, account_locked: false })
      .where(candidate: opted_in_candidates)
      .where.not(candidate: dismissed_candidates)
      .distinct
      .order(order_by)

    if active_location_filter?
      results
    else
      results.select(
        'application_forms.candidate_id, application_forms.first_name, application_forms.last_name, application_forms.submitted_at',
      )
    end
  end

private

  def filtered_application_forms
    scope = curated_application_forms
    scope = filter_by_subject(scope)
    scope = filter_by_study_mode(scope)
    scope = filter_by_course_type(scope)
    scope = filter_by_right_to_work_or_study(scope)
    # Need to improve this. can we do the distance bit different?
    filter_by_distance(scope)
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
      .where(
        id: ApplicationForm.joins(:application_choices)
            .where(application_choices: { status: ApplicationStateChange::UNSUCCESSFUL_STATES })
            .group(:id)
            # Inactive doesn't count as an unsuccessful state, so need to exclude it when counting
            .having("count(CASE WHEN application_choices.status != 'inactive' THEN 1 END) < #{ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS}")
            .select(:id),
      )
  end

  def filter_by_distance(scope)
    return scope unless active_location_filter?

    origin = filters.fetch(:origin)

    # This sql returns a number of miles from the origin location
    calculate_distance_sql = CandidateLocationPreference.distance_sql(
      Struct.new(:latitude, :longitude).new(
        latitude: origin.first,
        longitude: origin.last,
      ),
    )

    # Join lateral allows us to have a sub query in the join where we can only return 1 result
    # when searching for a location within a radius. Otherwise we will return the same application form
    # for each location_preference. Can't do distinct because the site_distance would be different
    results = scope.joins(candidate: :published_preferences)
      .joins(<<-SQL)
        join lateral (
          select * from candidate_location_preferences
          where candidate_location_preferences.candidate_preference_id = candidate_preferences.id
          group by id
          having(#{calculate_distance_sql} <= candidate_location_preferences.within)
          limit 1
        ) as candidate_location_preferences on true
      SQL
     .select("application_forms.candidate_id, application_forms.first_name,application_forms.last_name, #{calculate_distance_sql} as site_distance")

    Rails.logger.debug 'QUERY'
    Rails.logger.debug 'QUERY'
    Rails.logger.debug 'QUERY'
    Rails.logger.debug 'QUERY'
    Rails.logger.debug 'QUERY'
    Rails.logger.debug results.to_sql
    results
  end

  def filter_by_subject(scope)
    return scope if filters[:subject].blank?

    subjects = filters[:subject].flat_map { |value| value.split(',') }

    scope.joins(application_choices: { course: :course_subjects })
      .where(course_subjects: { subject_id: subjects })
  end

  def filter_by_study_mode(scope)
    return scope if filters[:study_mode].blank?

    scope.joins(application_choices: :course_option)
      .where(course_option: { study_mode: filters[:study_mode] })
  end

  def filter_by_course_type(scope)
    return scope if filters[:course_type].blank?

    course_types = filters[:course_type].flat_map { |value| value.split(',') }

    scope.joins(application_choices: :course)
      .where(course: { program_type: course_types })
  end

  def filter_by_right_to_work_or_study(scope)
    return scope if filters[:visa_sponsorship].blank?

    filter_values = filters[:visa_sponsorship].flat_map do |value|
      if value == 'required'
        # required means no right_to_work_or_study
        ApplicationForm.right_to_work_or_studies['no']
      else
        # else means all other enums + nil because we don't set this enum in most cases if candidate has right to work
        ApplicationForm.right_to_work_or_studies.except('no').values << nil
      end
    end

    scope.where(right_to_work_or_study: filter_values)
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
