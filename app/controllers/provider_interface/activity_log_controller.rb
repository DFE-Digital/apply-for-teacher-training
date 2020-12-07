module ProviderInterface
  class ActivityLogController < ProviderInterfaceController
    before_action :requires_provider_activity_log

    def index
      @events = GetActivityLogEvents.call(
        application_choices: GetApplicationChoicesForProviders.call(
          providers: current_provider_user.providers,
        ),
      ).page(params[:page] || 1).per(50)
    end

  private

    def requires_provider_activity_log
      unless FeatureFlag.active?(:provider_activity_log)
        redirect_to provider_interface_applications_path and return
      end
    end
  end
end
