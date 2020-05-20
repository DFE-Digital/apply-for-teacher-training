module ProviderInterface
  class ProviderApplicationsPageState
    attr_accessor :available_filters, :filter_selections, :provider_user

    def initialize(params:, provider_user:)
      @params = params
      @provider_user = provider_user
    end

    def filters
      ([] << search_filter << status_filter << provider_filter << accredited_provider_filter).compact
    end

    def filtered?
      applied_filters.values.any?
    end

    def applied_filters
      @params.permit(:candidate_name, provider: [], status: [], accredited_provider: []).to_h
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
      provider_options = ProviderOptionsService.new(provider_user).providers.map do |provider|
        {
          value: provider.id,
          label: provider.name,
          checked: applied_filters[:provider]&.include?(provider.id.to_s),
        }
      end

      provider_filter = {
        type: :checkboxes,
        heading: 'Provider',
        name: 'provider',
        options: provider_options,
      }

      return provider_filter if provider_filter[:options].size > 1

      nil
    end

    def accredited_provider_filter
      accredited_providers_options = ProviderOptionsService.new(provider_user).accredited_providers.map do |accredited_provider|
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
  end
end
