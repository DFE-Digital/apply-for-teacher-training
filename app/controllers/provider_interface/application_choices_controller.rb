module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      application_choices = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .order(updated_at: :desc)

      @application_choices = application_choices
    end

    def show
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end
  end
end
