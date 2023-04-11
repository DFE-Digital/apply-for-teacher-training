module ProviderInterface
  module Reports
    class DiversityReportsController < ProviderInterfaceController
      include CSVNameHelper

      def show
        @provider = current_user.providers.find(provider_id)
        @diversity_report_sex_data = DiversityDataByProvider.sex_data
        @diversity_report_disability_data = DiversityDataByProvider.disability_data
        @diversity_report_ethnicity_data = DiversityDataByProvider.ethnicity_data
        @diversity_report_age_data = DiversityDataByProvider.age_data
        @completed_e_and_d_survey_count = DiversityDataByProvider.completed_e_and_d_survey_count
        @total_submitted_applications = DiversityDataByProvider.total_submitted_applications
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end
    end
  end
end
