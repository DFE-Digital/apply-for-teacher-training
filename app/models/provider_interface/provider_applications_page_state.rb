module ProviderInterface
  class ProviderApplicationsPageState
    attr_accessor :sort_order, :sort_by, :available_filters, :filter_visible, :filter_selections

    def initialize(params:, application_choices:)
      @params = params
      @application_choices = application_choices
      @sort_order = calculate_sort_order
      @sort_by = calculate_sort_by
      @available_filters = calculate_available_filters
      @filter_visible =  calculate_filter_visibility
      @filter_selections = calculate_filter_selections
    end

    def applications_odering_query
      {
        'course' => { 'courses.name' => @sort_order },
        'last-updated' => { 'application_choices.updated_at' => @sort_order },
        'name' => { 'last_name' => @sort_order, 'first_name' => @sort_order },
      }[@sort_by]
    end

  private

    def calculate_filter_visibility
      filter_params[:filter_visible] ||= 'true'
    end

    def calculate_filter_selections
      filter_params[:filter_selections].to_h ||= {}
    end

    def filter_params
      @params.permit(:filter_visible, filter_selections: { status: {}, provider: {} })
    end

    def calculate_sort_order
      @params[:sort_order].eql?('asc') ? 'asc' : 'desc'
    end

    def calculate_sort_by
      @params[:sort_by].presence || 'last-updated'
    end


    def calculate_available_filters
      status_filters << provider_filters_builder
    end

    def status_filters
      [
        {
          heading: 'status',
          checkbox_config: [
            {
              name: 'pending-conditions',
              text: 'Accepted',
              value: 'pending_conditions',
            },
            {
              name: 'recruited',
              text: 'Conditions met',
              value: 'recruited',
            },
            {
              name: 'declined',
              text: 'Declined',
              value: 'declined',
            },
            {
              name: 'awaiting-provider-decision',
              text: 'New',
              value: 'awaiting_provider_decision',
            },
            {
              name: 'offer',
              text: 'Offered',
              value: 'offer',
            },
            {
              name: 'rejected',
              text: 'Rejected',
              value: 'rejected',
            },
            {
              name: 'withdrawn',
              text: 'Application withdrawn',
              value: 'withdrawn',
            },
            {
              name: 'offer-withdrawn',
              text: 'Withdrawn by us',
              value: 'offer_withdrawn',
            },
          ],
        },
      ]
    end

    def provider_filters_builder
      checkbox_config = @application_choices.map do |choice|
        provider = choice.provider

        {
          name: provider.name.parameterize,
          text: provider.name,
          value: provider.id.to_s,
        }
      end

      provider_filters = {
        heading: 'provider',
        checkbox_config: checkbox_config.uniq!,
      }

      provider_filters
    end

  end
end
