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
              text: 'Accepted',
              name: 'pending_conditions',
            },
            {
              text: 'Conditions met',
              name: 'recruited',
            },
            {
              text: 'Declined',
              name: 'declined',
            },
            {
              text: 'New',
              name: 'awaiting_provider_decision',
            },
            {
              text: 'Offered',
              name: 'offer',
            },
            {
              text: 'Rejected',
              name: 'rejected',
            },
            {
              text: 'Application withdrawn',
              name: 'withdrawn',
            },
            {
              text: 'Withdrawn by us',
              name: 'offer_withdrawn',
            },
          ],
        },
      ]
    end

    def provider_filters_builder
      checkbox_config = @application_choices.map do |choice|
        provider = choice.provider

        {
          text: provider.name,
          name: provider.id.to_s,
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
