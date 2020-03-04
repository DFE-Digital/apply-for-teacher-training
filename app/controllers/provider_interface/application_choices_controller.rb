module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      @sort_order = params[:sort_order].eql?('asc') ? 'asc' : 'desc'
      @sort_by = params[:sort_by].presence || 'last-updated'

      application_choices = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .order(ordering_arguments(@sort_by, @sort_order))

      application_choices = application_choices.page(params[:page] || 1)

      if FeatureFlag.active?('provider_application_filters')
         @available_filters = available_filters(application_choices: application_choices)
         @filter_visible =  filter_params[:filter_visible] ||= 'true'
         @filter_selections = filter_params[:filter_selections].to_h ||= {}
         @application_choices = FilterApplicationChoicesForProviders.call(application_choices: application_choices,
                                                                          filters: @filter_selections)
      else
        @application_choices = application_choices
      end
    end

    def show
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

  private

    def filter_params
      params.permit(:filter_visible,  filter_selections: {status: {}, provider: {}})
    end

    def ordering_arguments(sort_by, sort_order)
      {
        'course' => { 'courses.name' => sort_order },
        'last-updated' => { 'application_choices.updated_at' => sort_order },
        'name' => { 'last_name' => sort_order, 'first_name' => sort_order },
      }[sort_by]
    end

    def available_filters(application_choices:)
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
 }
      ] << provider_filters(application_choices: application_choices)
    end

    def provider_filters(application_choices:)
      {
        heading: 'provider',
        checkbox_config: application_choices.map do |choice|
          provider = choice.provider
          {
            name: provider.name.parameterize,
            text: provider.name,
            value: provider.id.to_s,
          }
        end.uniq!
      }
    end

  end
end
