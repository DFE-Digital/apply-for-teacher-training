module SupportInterface
  class StatusOfActiveApplicationsController < SupportInterfaceController
    include CSVNameHelper

    before_action :set_provider

    def show
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

  private

    def set_provider
      @provider ||= Provider.find(params.permit(:provider_id)[:provider_id])
    end
  end
end
