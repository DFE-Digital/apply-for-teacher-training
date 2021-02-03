module SupportInterface
  class ProvidersFilter
    attr_reader :applied_filters
    ONBOARDING_STAGES = {
      'synced' => 'Courses synced',
      'dsa_signed' => 'DSA signed',
    }.freeze

    DEFAULT_STATE = {
      onboarding_stages: ONBOARDING_STAGES.keys,
    }.freeze

    def initialize(params:)
      @applied_filters = params.slice(:remove, :onboarding_stages, :q).presence || DEFAULT_STATE
    end

    def filters
      onboarding_state_options = ONBOARDING_STAGES.map do |name, label|
        {
          value: name,
          label: label,
          checked: applied_filters[:onboarding_stages]&.include?(name),
        }
      end

      [
        {
          type: :checkboxes,
          heading: 'Onboarding stage',
          options: onboarding_state_options,
          name: 'onboarding_stages',
        },
        {
          type: :search,
          heading: 'Name or code',
          value: applied_filters[:q],
          name: 'q',
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

      providers
    end
  end
end
