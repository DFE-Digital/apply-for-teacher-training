module ProviderInterface
  module Reports
    class RecruitmentPerformanceReportsController < ProviderInterfaceController
      before_action :set_provider
      before_action :set_region

      def show
        @provider_report = latest_report.present? ? Publications::ProviderRecruitmentPerformanceReportPresenter.new(latest_report) : nil
        @report_type = @region == all_of_england ? :NATIONAL : :REGIONAL

        respond_to do |format|
          format.html do
            @provider_data = @provider_report&.statistics
            @statistics = @region == all_of_england ? national_report&.statistics : regional_report&.statistics
          end
          format.zip do
            if latest_report.present?
              exporter

              send_file(
                exporter,
                filename: "#{@provider.name.parameterize}-recruitment-performance-report-#{Time.zone.today}.zip",
                type: 'application/zip',
              )
            else
              head :not_found
            end
          end
        end
      end

    private

      def exporter
        @exporter ||= ProviderInterface::RecruitmentPerformanceReportExport.new(
          provider: @provider,
          region: @region,
          provider_report: @provider_report,
          report_type: @report_type,
        ).call
      end

      def set_provider
        @provider ||= current_user.providers.find(
          params.permit(:provider_id)[:provider_id],
        )
      end

      def all_of_england
        Publications::RegionalRecruitmentPerformanceReport.all_of_england_key
      end

      def set_region
        @region = RegionalReportFilter.find_by(
          provider_id: @provider.id,
          provider_user_id: current_user.id,
        )&.region || all_of_england
      end

      def regional_report
        if @provider_report.present?
          @regional_report ||=
            Publications::RegionalRecruitmentPerformanceReport.where(
              cycle_week: @provider_report.cycle_week,
              region: @region,
            ).last
        end
      end

      def national_report
        if @provider_report.present?
          @national_report ||=
            Publications::NationalRecruitmentPerformanceReport.where(
              cycle_week: @provider_report.cycle_week,
            ).last
        end
      end

      def latest_report
        Publications::ProviderRecruitmentPerformanceReport
          .where(provider: @provider)
          .order(:recruitment_cycle_year, :cycle_week)
          .last
      end
    end
  end
end
