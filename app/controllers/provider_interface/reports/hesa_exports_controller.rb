module ProviderInterface
  class HesaExportController < ProviderInterfaceController
    before_action :render_404_unless_feature_enabled

    def export
      respond_to do |format|
        format.csv do
          csv_data = HesaDataExport.new(actor: current_provider_user).call
          send_data csv_data, disposition: 'attachment', filename: csv_filename
        end
      end
    end

  private

    def csv_filename
      "#{Time.zone.now}.applications-export.csv"
    end

    def render_404_unless_feature_enabled
      render_404 unless FeatureFlag.active?(:export_hesa_data)
    end
  end
end
