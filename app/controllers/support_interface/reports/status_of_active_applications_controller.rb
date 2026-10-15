module SupportInterface
  module Reports
    class StatusOfActiveApplicationsController < SupportInterfaceController
      before_action :set_provider

      def show
        @provider_report = ProviderReport.new(provider_id: @provider.id)

        respond_to do |format|
          format.csv do
            csv_data = StatusOfActiveApplicationsExport.new(provider: @provider).call
            send_data csv_data, disposition: 'attachment', filename: csv_filename(export_name: 'status-of-active-applications', cycle_years: [current_timetable.recruitment_cycle_year], providers: [@provider])
          end
          format.html do
            @active_application_status_data = ActiveApplicationStatusesByProvider.new(@provider).call
          end
        end
      end

      def set_provider
        @provider ||= Provider.find_by(
          id: params[:support_interface_provider_report]&.fetch(:provider_id, nil),
        ) || Provider.first
      end
    end
  end
end
