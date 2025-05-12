module ProviderInterface
  module Reports
    class StatusOfActiveApplicationsController < ProviderInterfaceController
      include CSVNameHelper

      def show
        @provider = current_user.providers.find(provider_id)
        respond_to do |format|
          format.csv do
            csv_data = ProviderInterface::StatusOfActiveApplicationsExport.new(provider: @provider).call
            send_data csv_data, disposition: 'attachment', filename: csv_filename(export_name: 'status-of-active-applications', cycle_years: [current_timetable.recruitment_cycle_year], providers: [@provider])
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
    end
  end
end
