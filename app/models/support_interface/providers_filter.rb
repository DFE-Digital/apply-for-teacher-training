module SupportInterface
  class ProvidersFilter
    include FilterParamsHelper

    attr_reader :applied_filters
    ONBOARDING_STAGES = {
      'with_courses' => 'With courses',
      'dsa_unsigned_only' => 'With unsigned DSAs',
      'dsa_signed_only' => 'With signed DSAs',
    }.freeze

    PROVIDER_TYPES = {
      'lead_school' => 'School Direct',
      'scitt' => 'SCITT',
      'university' => 'HEI',
    }.freeze

    RATIFIED_BY = {
      'scitt' => 'SCITT',
      'university' => 'HEI',
    }.freeze

    def initialize(params:)
      @applied_filters = compact_params(
        params.slice(
          :remove,
          :provider_types,
          :ratified_by,
          :onboarding_stages,
          :q,
          :no_provider_users,
          :accredited_provider,
        ),
      )
    end

    def filters
      [
        {
          type: :search,
          heading: 'Name or code',
          value: applied_filters[:q],
          name: 'q',
        },
        {
          type: :search,
          heading: 'Name or code of accredited body',
          value: applied_filters[:accredited_provider],
          name: 'accredited_provider',
        },
        {
          type: :checkboxes,
          heading: 'Onboarding stage',
          options: hash_to_checkbox_options(:onboarding_stages, ONBOARDING_STAGES),
          name: 'onboarding_stages',
        },
        {
          type: :checkboxes,
          heading: 'Provider type',
          options: hash_to_checkbox_options(:provider_types, PROVIDER_TYPES),
          name: 'provider_types',
        },
        {
          type: :checkboxes,
          heading: 'Ratified by (only applies to providers with synced courses)',
          options: hash_to_checkbox_options(:ratified_by, RATIFIED_BY),
          name: 'ratified_by',
        },
        {
          type: :checkboxes,
          heading: 'No provider users',
          name: 'no_provider_users',
          options: [
            {
              value: true,
              label: 'Has no provider users',
              checked: applied_filters[:no_provider_users]&.include?('true'),
            },
          ],
        },
      ]
    end

    def filter_records(providers)
      if applied_filters[:q].present?
        providers = providers.where("CONCAT(providers.name, ' ', providers.code) ILIKE ?", "%#{applied_filters[:q]}%")
        @search_count = providers.count
      else
        @search_count = 0
      end

      if applied_filters[:onboarding_stages]&.include?('with_courses')
        providers = providers.with_courses
      end

      if applied_filters[:onboarding_stages]&.include?('dsa_signed_only')
        providers = providers.joins(:provider_agreements)
      end

      if applied_filters[:onboarding_stages]&.include?('dsa_unsigned_only')
        providers = providers.where.missing(:provider_agreements)
      end

      if applied_filters[:provider_types].present?
        providers = providers.where(provider_type: applied_filters[:provider_types])
      end

      if applied_filters[:ratified_by].present?
        ratifiers = Provider.where(provider_type: applied_filters[:ratified_by])
        providers = providers.joins(:training_provider_permissions)
          .where(provider_relationship_permissions: { ratifying_provider_id: ratifiers })
          .distinct
      end

      if applied_filters[:no_provider_users].present?
        providers = providers.left_outer_joins(:provider_permissions).where(provider_users_providers: { id: nil })
      end

      if applied_filters[:accredited_provider].present?
        accrediting_provider_ids = Provider
                                    .where('providers.name ILIKE ? OR providers.code ILIKE ?', "%#{applied_filters[:accredited_provider]}%", "%#{applied_filters[:accredited_provider]}%")
                                    .map(&:id)

        providers = providers
                    .distinct
                    .joins(:courses)
                    .where(courses: { accredited_provider_id: accrediting_provider_ids, recruitment_cycle_year: RecruitmentCycleTimetable.current_year })
      end

      @filtered_count = providers.count
      providers
    end

    def search_results_filtered_out_count
      @search_count - @filtered_count
    end

  private

    def hash_to_checkbox_options(option_name, hash)
      hash.map do |name, label|
        {
          value: name,
          label:,
          checked: applied_filters[option_name]&.include?(name),
        }
      end
    end
  end
end
