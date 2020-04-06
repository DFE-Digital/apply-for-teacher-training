module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      @page_state = ProviderApplicationsPageState.new(
        params: params,
        provider_user: current_provider_user,
      )

      application_choices = GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
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
      available_providers = current_provider_user.providers

      @application_choice = GetApplicationChoicesForProviders.call(
        providers: available_providers,
      ).find(params[:application_choice_id])

      @status_box_options = if @application_choice.offer?
                              GetAllChangeOptionsFromOfferedOption.new(
                                application_choice: @application_choice,
                                available_providers: available_providers,
                              ).call.merge(application_choice: @application_choice)
                            else
                              { application_choice: @application_choice }
                            end
    end
  end
end
