module ProviderInterface
  module Reports
    class HesaExportsController < ProviderInterfaceController
      include StreamableDataExport

      def show
        year = params[:year]
        respond_to do |format|
          format.csv do
            hesa_data_export = HesaDataExport.new(actor: current_provider_user, recruitment_cycle_year: year)
            self.response_body = streamable_response(
              filename: csv_filename(year),
              export_headings: hesa_data_export.export_row(hesa_data_export.export_data.first).keys,
              export_data: hesa_data_export.export_data,
              item_yielder: proc { |item| hesa_data_export.export_row(item).values },
            )
          end
        end
      end

      def index; end

    private

      def csv_filename(year)
        "#{Time.zone.now}.#{year}.applications-export.csv"
      end
    end
  end
end
