module ProviderInterface
  module Reports
    class StatusOfActiveApplicationsController < ProviderInterfaceController
      def show
        provider_id = params[:provider_id]
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

      def csv_filename(provider)
        "#{Time.zone.now},#{provider.name}.status_of_active_applications.csv"
      end
    end
  end
end
