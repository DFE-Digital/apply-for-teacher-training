module ProviderInterface
  module Reports
    class DiversityReportsController < ProviderInterfaceController
      include CSVNameHelper

      def show
        @provider = current_user.providers.find(provider_id)
        @diversity_report_sex_data = []
        @diversity_report_disability_data = []
        @diversity_report_ethnicity_data = []
        @diversity_report_age_data = []
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end
    end
  end
end
