module ProviderInterface
  module Reports
    class StatusOfActiveApplicationsController < ProviderInterfaceController
      before_action :redirect_if_reports_dashboard_feature_flag_is_off

      def show
        @provider = current_user.providers.find(provider_id)
        respond_to do |format|
          format.csv do
            csv_data = ProviderInterface::StatusOfActiveApplicationsExport.new(provider: @provider).call
            send_data csv_data, disposition: 'attachment', filename: csv_filename(@provider)
          end
          format.html do
            @active_application_status_data = ActiveApplicationStatusesByProvider.new(@provider).call
          end
        end
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end

      def csv_filename(provider)
        "#{Time.zone.now},#{provider.name}.status_of_active_applications.csv"
      end

      def redirect_if_reports_dashboard_feature_flag_is_off
        return if FeatureFlag.active?(:provider_reports_dashboard)

        redirect_to provider_interface_reports_path
      end
    end
  end
end
