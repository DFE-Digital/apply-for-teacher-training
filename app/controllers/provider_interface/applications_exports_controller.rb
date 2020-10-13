module ProviderInterface
  class ApplicationsExportsController < ProviderInterfaceController
    def export
      respond_to do |format|
        format.csv do
          csv_data = HesaDataExport.new(provider_ids: current_provider_user.providers.map(&:id)).call
          send_data csv_data, disposition: 'attachment', filename: csv_filename
        end
      end
    end

  private

    def csv_filename
      "#{Time.zone.now}.applications-export.csv"
    end
  end
end
