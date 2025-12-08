module ProviderInterface
  module Reports
    class DiversityReportsController < ProviderInterfaceController
      attr_reader :diversity_data, :provider, :recruitment_cycle_timetable
      before_action :set_recruitment_cycle_timetable, only: :show
      before_action :redirect_to_current_year_if_invalid_year

      def show
        @provider = current_user.providers.find(provider_id)
        zip_filename = ProviderInterface::DiversityReportExport.new(
          provider:, recruitment_cycle_year:
          recruitment_cycle_timetable.recruitment_cycle_year
        ).call

        respond_to do |format|
          format.zip do
            send_file(
              zip_filename,
              filename: "#{provider.name.parameterize}-diversity-report-#{Time.zone.today}.zip",
              type: 'application/zip',
            )
          end

          format.html do
            @diversity_data = DiversityDataByProvider.new(
              provider:,
              recruitment_cycle_year: recruitment_cycle_timetable.recruitment_cycle_year,
            )
            @diversity_report_sex_data = diversity_data.sex_data
            @diversity_report_candidate_disability_data = diversity_data.candidates_with_disability_data
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

      def redirect_to_current_year_if_invalid_year
        if @recruitment_cycle_timetable.blank?
          redirect_to provider_interface_reports_provider_diversity_report_path
        end
      end

      def set_recruitment_cycle_timetable
        year = params[:recruitment_cycle_year]&.to_i

        @recruitment_cycle_timetable = if year.blank?
                                         RecruitmentCycleTimetable.current_timetable
                                       elsif year.in? RecruitmentCycleTimetable.years_visible_to_providers
                                         RecruitmentCycleTimetable.find_by(recruitment_cycle_year: year)
                                       end
      end
    end
  end
end
