module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      application_choices = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)

      @page_state = ProviderApplicationsPageState.new(params: params, application_choices: application_choices)

      if FeatureFlag.active?('provider_application_filters')
        @filter_visible = @page_state.filter_visible
        @filter_selections = @page_state.filter_selections
        application_choices = FilterApplicationChoicesForProviders.call(application_choices: application_choices,
                                                                        filters: @filter_selections)
      end
      application_choices = application_choices.page(params[:page] || 1)
      @application_choices = application_choices.order(@page_state.applications_odering_query)
    end

    def show
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

  private

    def filter_params
      params.permit(:filter_visible, filter_selections: { status: {}, provider: {} })
    end

  end
end
