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
      .where(candidate: { pool_status: :opt_in })
      .where.not(candidate_id: dismissed_candidates.ids)
      .order(order_by)
  end

private

  def filtered_application_forms
    scope = curated_application_forms
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
    ).map(&:id)

    scope.joins(application_choices: { course_option: :site })
      .where('application_choices.created_at = ( select max(created_at) from application_choices where application_choices.application_form_id = application_forms.id)')
      .where(sites: { id: site_ids })
      .select('application_forms.*', "#{calculate_distance_sql} AS site_distance")
  end

  def filter_by_right_to_work_or_study(scope)
    return scope if filters[:visa_sponsorship].blank?

    filter_values = filters[:visa_sponsorship].flat_map do |value|
      value == 'required' ? 'no' : nil # required means no right_to_work_or_study, nil means yes
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
