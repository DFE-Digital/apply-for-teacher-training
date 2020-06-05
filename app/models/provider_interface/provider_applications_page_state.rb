module ProviderInterface
  class ProviderApplicationsPageState
    attr_accessor :available_filters, :filter_selections, :provider_user

    def initialize(params:, provider_user:)
      @params = params
      @provider_user = provider_user
    end

    def filters
      ([] << search_filter << status_filter << provider_filter << accredited_provider_filter).concat(provider_locations_filters).compact
    end

    def filters_visible?
      if applied_filters[:filters_visible]
        applied_filters[:filters_visible].first.eql?('true') ? true : false
      else
        true
      end
    end

    def filtered?
      applied_filters.values.any?
    end

    def applied_filters
      @params.permit(:candidate_name, provider: [], status: [], accredited_provider: [], provider_location: [], filters_visible: []).to_h
    end

  private

    def search_filter
      {
        type: :search,
        heading: 'Candidate’s name',
        value: applied_filters[:candidate_name],
        name: 'candidate_name',
      }
    end

    def status_filter
      status_options = %w[
        awaiting_provider_decision
        offer
        pending_conditions
        recruited
        enrolled
        rejected
        declined
        withdrawn
        conditions_not_met
        offer_withdrawn
      ].map do |state_name|
        {
          value: state_name,
          label: I18n.t!("provider_application_states.#{state_name}"),
          checked: applied_filters[:status]&.include?(state_name),
        }
      end

      {
        type: :checkboxes,
        heading: 'Status',
        name: 'status',
        options: status_options,
      }
    end

    def provider_filter
      providers = ProviderOptionsService.new(provider_user).providers

      return nil if providers.size < 2

      provider_options = providers.map do |provider|
        {
          value: provider.id,
          label: provider.name,
          checked: applied_filters[:provider]&.include?(provider.id.to_s),
        }
      end

      {
        type: :checkboxes,
        heading: 'Provider',
        name: 'provider',
        options: provider_options,
      }
    end

    def accredited_provider_filter
      accredited_providers = ProviderOptionsService.new(provider_user).accredited_providers

      return nil if accredited_providers.empty?

      accredited_providers_options = accredited_providers.map do |accredited_provider|
        {
          value: accredited_provider.id,
          label: accredited_provider.name,
          checked: applied_filters[:accredited_provider]&.include?(accredited_provider.id.to_s),
        }
      end

      {
        type: :checkboxes,
        heading: 'Accredited provider',
        name: 'accredited_provider',
        options: accredited_providers_options,
      }
    end

    def provider_locations_filters
      return [] if applied_filters[:provider].nil?

      providers = ProviderOptionsService.new(provider_user).providers_with_sites(provider_ids: applied_filters[:provider])

      providers.map do |p|
        next unless p.sites.count > 1

        {
          type: :checkboxes,
          heading: "Locations for #{p.name}",
          name: 'provider_location',
          options: p.sites.map do |s|
            {
              value: s.id,
              label: s.name,
              checked: applied_filters[:provider_location]&.include?(s.id.to_s),
            }
          end,
        }
      end
    end
  end
end
