module ProviderInterface
  module Reports
    class HesaExportsController < ProviderInterfaceController
      before_action :render_404_unless_feature_enabled

      def show
        year = params[:year]
        respond_to do |format|
          format.csv do
            csv_data = HesaDataExport.new(actor: current_provider_user, recruitment_cycle_year: year).call
            send_data csv_data, disposition: 'attachment', filename: csv_filename(year)
          end
        end
      end

      def index; end

    private

      def csv_filename(year)
        "#{Time.zone.now}.#{year}.applications-export.csv"
      end

      def render_404_unless_feature_enabled
        render_404 unless FeatureFlag.active?(:export_hesa_data)
      end
    end
  end
end
