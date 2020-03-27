module ProviderInterface
  class ProviderApplicationsPageState
    attr_accessor :sort_order, :sort_by, :available_filters, :filter_visible, :filter_selections, :provider_user

    def initialize(params:, application_choices:, provider_user:)
      @params = params
      @application_choices = application_choices
      @provider_user = provider_user
      @sort_order = calculate_sort_order
      @sort_by = calculate_sort_by
      @available_filters = calculate_available_filters
      @filter_visible =  calculate_filter_visibility
      @filter_selections = calculate_filter_selections
    end

    def applications_ordering_query
      {
        'course' => { 'courses.name' => @sort_order },
        'last-updated' => { 'application_choices.updated_at' => @sort_order },
        'name' => { 'last_name' => @sort_order, 'first_name' => @sort_order },
      }[@sort_by]
    end

    def to_h
      {
        sort_order: @sort_order,
        sort_by: @sort_by,
        filter_visible: @filter_visible,
        filter_selections: @filter_selections,
      }
    end

  private

    def calculate_filter_visibility
      filter_params[:filter_visible] ||= 'true'
    end

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
      @params.permit(:filter_visible, filter_selections: { search: {}, status: {}, provider: {}, accrediting_provider: {} })
    end

    def calculate_sort_order
      @params[:sort_order].eql?('asc') ? 'asc' : 'desc'
    end

    def calculate_sort_by
      @params[:sort_by].presence || 'last-updated'
    end

    def calculate_available_filters
      search_filters << status_filters << provider_filters_builder << accrediting_provider_filters_builder
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
      {
        heading: 'status',
        input_config: [
          {
            type: 'checkbox',
            text: 'Accepted',
            name: 'pending_conditions',
          },
          {
            type: 'checkbox',
            text: 'Conditions met',
            name: 'recruited',
          },
          {
            type: 'checkbox',
            text: 'Declined',
            name: 'declined',
          },
          {
            type: 'checkbox',
            text: 'New',
            name: 'awaiting_provider_decision',
          },
          {
            type: 'checkbox',
            text: 'Offered',
            name: 'offer',
          },
          {
            type: 'checkbox',
            text: 'Rejected',
            name: 'rejected',
          },
          {
            type: 'checkbox',
            text: 'Application withdrawn',
            name: 'withdrawn',
          },
          {
            type: 'checkbox',
            text: 'Withdrawn by us',
            name: 'offer_withdrawn',
          },
        ],
      }
    end

    def provider_filters_builder
      input_config = @application_choices.map do |choice|
        provider = choice.provider

        {
          type: 'checkbox',
          text: provider.name,
          name: provider.id.to_s,
        }
      end

      provider_filters = {
        heading: 'provider',
        input_config: input_config.uniq,
      }

      provider_filters
    end

    # TODO:
    # * Updated/New system spec
    # * Query provider_user -> providers -> courses -> accrediting_providers to get options DONE
    # * Update tests for ProviderApplicationsPageState DONE
    # * Implement filtering on the query itself
    # * Check that filter selections are preserved
    # * Raise issue about Provider filter (is it efficient?)

    def accrediting_provider_filters_builder
      input_config = ProviderOptionsService.new(provider_user).accrediting_providers.map do |provider|
        {
          type: 'checkbox',
          text: provider.name,
          name: provider.id.to_s,
        }
      end

      {
        heading: 'accrediting_provider',
        input_config: input_config.uniq,
      }
    end
  end
end
