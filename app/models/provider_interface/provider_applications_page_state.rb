module ProviderInterface
  class ProviderApplicationsPageState
    attr_accessor :available_filters, :filter_selections, :provider_user

    def initialize(params:, provider_user:)
      @params = params
      @provider_user = provider_user
      @available_filters = calculate_available_filters
      @filter_selections = calculate_filter_selections
    end

    def to_h
      {
        filter_selections: @filter_selections,
      }
    end

  private

    def calculate_filter_selections
      filter_selections = filter_params[:filter_selections].to_h ||= {}
      remove_candiates_name_search_if_empty(filter_selections)
    end

    def remove_candiates_name_search_if_empty(filter_selections)
      return filter_selections if filter_selections.empty?

      filter_selections.delete(:search) if filter_selections.dig(:search, :candidates_name) == ''
      filter_selections
    end

    def filter_params
      @params.permit(filter_selections: { search: {}, status: {}, provider: {}, accredited_provider: {} })
    end

    def calculate_available_filters
      search_filters << status_filters << provider_filters_builder << accredited_provider_filters_builder
    end

    def search_filters
      [
        {
          heading: 'candidate\'s name',
          input_config: [{
            type: 'search',
            text: '',
            name: 'candidates_name',
          }],
        },
      ]
    end

    def status_filters
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
          type: 'checkbox',
          text: I18n.t!("provider_application_states.#{state_name}"),
          name: state_name,
        }
      end

      {
        heading: 'status',
        input_config: status_options,
      }
    end

    def provider_filters_builder
      input_config = ProviderOptionsService.new(provider_user).providers.map do |provider|
        {
          type: 'checkbox',
          text: provider.name,
          name: provider.id.to_s,
        }
      end

      {
        heading: 'provider',
        input_config: input_config,
      }
    end

    def accredited_provider_filters_builder
      input_config = ProviderOptionsService.new(provider_user).accredited_providers.map do |provider|
        {
          type: 'checkbox',
          text: provider.name,
          name: provider.id.to_s,
        }
      end

      {
        heading: 'accredited_provider',
        input_config: input_config,
      }
    end
  end
end
