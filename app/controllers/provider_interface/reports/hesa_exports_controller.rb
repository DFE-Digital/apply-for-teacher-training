module ProviderInterface
  module Reports
    class HesaExportsController < ProviderInterfaceController
      include ActionController::Live
      include CSVNameHelper
      include StreamableDataExport

      def index
        @previous_timetable = @current_timetable.relative_previous_timetable
      end

      def show
        respond_to do |format|
          format.csv do
            year = params[:year]
            exporter = HesaDataExport.new(
              actor: current_provider_user,
              recruitment_cycle_year: year,
            )
            filename = csv_filename(
              export_name: 'hesa-data',
              cycle_years: [year],
              providers: current_provider_user.providers,
            )

            stream_csv(data: exporter.export_data, filename:) do |row|
              exporter.export_row(row)
            end
          end
        end
      end
    end
  end
end
