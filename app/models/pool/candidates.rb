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
    dismissed_candidates = Candidate.joins(:pool_dismissals).where(pool_dismissals: { provider: providers })

    filtered_application_forms.joins(:candidate)
      .where(candidate: { pool_status: :opt_in, submission_blocked: false, account_locked: false })
      .where.not(candidate_id: dismissed_candidates.ids)
      .order(order_by)
      .distinct
  end

private

  def filtered_application_forms
    scope = curated_application_forms
    scope = filter_by_subject(scope)
    scope = filter_by_study_mode(scope)
    scope = filter_by_course_type(scope)
    scope = filter_by_right_to_work_or_study(scope)
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

    calculate_distance_sql = Site.distance_sql(
      Struct.new(:latitude, :longitude).new(
        latitude: filters.fetch(:origin).first,
        longitude: filters.fetch(:origin).last,
      ),
    )

    site_ids = Site.within(
      filters.fetch(:within),
      units: :miles,
      origin:,
    ).select(:id)

    scope.joins(application_choices: { course_option: :site })
      # get the last sent application_choice
      .where('application_choices.sent_to_provider_at = ( select max(sent_to_provider_at) from application_choices where application_choices.application_form_id = application_forms.id)')
      .where(sites: { id: site_ids })
      .select('application_forms.*', "#{calculate_distance_sql} AS site_distance")
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
    filters[:within].present? && filters[:origin].present?
  end

  def order_by
    if active_location_filter?
      'site_distance ASC'
    else
      'application_forms.submitted_at'
    end
  end
end
