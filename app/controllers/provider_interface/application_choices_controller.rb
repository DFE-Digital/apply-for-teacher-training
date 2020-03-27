module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      application_choices = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)

      @page_state = ProviderApplicationsPageState.new(
        params: params,
        application_choices: application_choices,
        provider_user: provider_user,
      )

      if FeatureFlag.active?('provider_application_filters')
        application_choices = FilterApplicationChoicesForProviders.call(
          application_choices: application_choices,
          filters: @page_state.filter_selections,
        )
      end
      application_choices = application_choices.page(params[:page] || 1)
      @application_choices = application_choices.order(@page_state.applications_ordering_query)
    end

    def show
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end
  end
end
