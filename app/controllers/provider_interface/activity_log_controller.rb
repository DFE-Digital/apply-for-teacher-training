module ProviderInterface
  class ActivityLogController < ProviderInterfaceController
    def index
      @events = GetActivityLogEvents.call(
        application_choices: GetApplicationChoicesForProviders.call(
          providers: current_provider_user.providers,
        ),
      ).page(params[:page] || 1).per(50)
    end
  end
end
