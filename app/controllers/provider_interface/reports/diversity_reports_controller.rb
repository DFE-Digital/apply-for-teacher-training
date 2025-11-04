module ProviderInterface
  module Reports
    class DiversityReportsController < ProviderInterfaceController
      attr_reader :diversity_data, :provider, :recruitment_cycle_year

      def show
        @recruitment_cycle_year = RecruitmentCycleTimetable.current_year
        @provider = current_user.providers.find(provider_id)
        zip_filename = ProviderInterface::DiversityReportExport.new(provider:, recruitment_cycle_year:).call

        respond_to do |format|
          format.zip do
            send_file(
              zip_filename,
              filename: "#{provider.name.parameterize}-diversity-report-#{Time.zone.today}.zip",
              type: 'application/zip',
            )
          end

          format.html do
            @diversity_data = DiversityDataByProvider.new(provider:, recruitment_cycle_year:)
            @diversity_report_sex_data = diversity_data.sex_data
            @diversity_report_disability_data = diversity_data.disability_data
            @diversity_report_ethnicity_data = diversity_data.ethnicity_data
            @diversity_report_age_data = diversity_data.age_data
            @total_submitted_applications = diversity_data.total_submitted_applications
          end
        end
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end
    end
  end
end
