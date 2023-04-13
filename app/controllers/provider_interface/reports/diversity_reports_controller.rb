module ProviderInterface
  module Reports
    class DiversityReportsController < ProviderInterfaceController
      include CSVNameHelper
      attr_reader :diversity_data, :provider

      def show
        @provider = current_user.providers.find(provider_id)
        @diversity_data = DiversityDataByProvider.new(provider: provider)
        @diversity_report_sex_data = diversity_data.sex_data
        @diversity_report_disability_data = diversity_data.disability_data
        @diversity_report_ethnicity_data = diversity_data.ethnicity_data
        @diversity_report_age_data = diversity_data.age_data
        @completed_e_and_d_survey_count = diversity_data.completed_e_and_d_survey_count
        @total_submitted_applications = diversity_data.total_submitted_applications
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end
    end
  end
end
