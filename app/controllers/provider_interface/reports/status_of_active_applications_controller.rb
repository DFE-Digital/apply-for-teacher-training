module ProviderInterface
  module Reports
    class StatusOfActiveApplicationsController < ProviderInterfaceController
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
        "Status of active applications - #{provider.name} - #{RecruitmentCycle.cycle_name} - #{Time.zone.now.strftime('%F-%H_%M_%S')}.csv"
      end
    end
  end
end
