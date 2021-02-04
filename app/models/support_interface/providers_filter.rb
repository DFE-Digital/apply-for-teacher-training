module SupportInterface
  class ProvidersFilter
    attr_reader :applied_filters
    ONBOARDING_STAGES = {
      'synced' => 'Courses synced',
      'dsa_signed' => 'DSA signed',
    }.freeze

    PROVIDER_TYPES = {
      'lead_school' => 'School Direct',
      'scitt' => 'SCITT',
      'university' => 'HEI',
    }

    DEFAULT_STATE = {
      onboarding_stages: ONBOARDING_STAGES.keys,
    }.freeze

    def initialize(params:)
      @applied_filters = params.slice(
        :remove,
        :provider_types,
        :onboarding_stages,
        :q,
      ).presence || DEFAULT_STATE
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
      ]
    end

    def filter_records(providers)
      if applied_filters[:q]
        providers = providers.where("CONCAT(providers.name, ' ', providers.code) ILIKE ?", "%#{applied_filters[:q]}%")
      end

      if applied_filters[:onboarding_stages]&.include?('synced')
        providers = providers.where(sync_courses: true)
      else
        providers = providers.where(sync_courses: false)
      end

      if applied_filters[:onboarding_stages]&.include?('dsa_signed')
        providers = providers.joins(:provider_agreements)
      else
        providers = providers.includes(:provider_agreements).where(provider_agreements: { provider_id: nil })
      end

      if applied_filters[:provider_types].present?
        providers = providers.where(provider_type: applied_filters[:provider_types])
      end

      providers
    end

  private

    def hash_to_checkbox_options(option_name, hash)
      hash.map do |name, label|
        {
          value: name,
          label: label,
          checked: applied_filters[option_name]&.include?(name),
        }
      end
    end
  end
end
