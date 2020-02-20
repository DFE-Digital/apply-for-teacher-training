module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      @page_state = ProviderApplicationsPageState.new(params: params)

      application_choices = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .order(@page_state.ordering_arguments)

      filtered_application_choices = FilterApplicationChoicesForProviders.call(application_choices: application_choices, page_state: @page_state)

      @application_choices = filtered_application_choices
    end

    def show
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

  end
end
