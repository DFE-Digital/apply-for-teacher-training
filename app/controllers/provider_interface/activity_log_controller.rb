module ProviderInterface
  class ActivityLogController < ProviderInterfaceController
    include Pagy::Backend

    def index
      application_choices = GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
      )
      events = GetActivityLogEvents.call(
        application_choices: application_choices,
      )
      @pagy, @events = pagy(events, items: 50)
    end
  end
end
