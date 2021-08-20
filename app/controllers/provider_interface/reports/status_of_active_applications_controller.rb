module ProviderInterface
  module Reports
    class StatusOfActiveApplicationsController < ProviderInterfaceController
      def show
        provider_id = params[:provider_id]
        @provider = current_user.providers.find(provider_id)
        @active_application_status_data = ActiveApplicationStatusesByProvider.new(@provider).call
      end
    end
  end
end
