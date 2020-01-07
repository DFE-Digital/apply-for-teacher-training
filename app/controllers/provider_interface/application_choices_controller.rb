module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      application_choices = GetApplicationChoicesForProvider.call(provider: current_provider_user.provider)
        .order(updated_at: :desc)

      @application_choices = application_choices
    end

    def show
      @application_choice = GetApplicationChoicesForProvider.call(provider: current_provider_user.provider)
        .find(params[:application_choice_id])
    end
  end
end
