module ProviderInterface
  class ActivityLogController < ProviderInterfaceController
    include Pagy::Backend

    PAGY_PER_PAGE = 50

    def index
      redirect_to provider_interface_applications_path

      application_choices = GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
      )
      events = GetActivityLogEvents.call(application_choices:)
      @pagy, @events = pagy(events, limit: PAGY_PER_PAGE)
    end
  end
end
