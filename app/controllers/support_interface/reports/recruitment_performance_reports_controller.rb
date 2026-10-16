module SupportInterface
  module Reports
    class RecruitmentPerformanceReportsController < SupportInterfaceController
      before_action :set_provider
      before_action :set_region
      before_action :set_cycle_year

      def show
        # need to delete this
        @provider_form = ProviderReport.new(provider_id: @provider.id)
        @provider_report = latest_report.present? ? Publications::ProviderRecruitmentPerformanceReportPresenter.new(latest_report) : nil
        @report_type = @region == all_of_england ? :NATIONAL : :REGIONAL
        @provider_edi_reports = Publications::ProviderEdiReport.where(
          provider: @provider,
          cycle_week: @provider_report&.cycle_week,
          recruitment_cycle_year: @provider_report&.recruitment_cycle_year,
          category: ReportSharedEnums.edi_categories.keys,
        ).select('DISTINCT ON (category) *').order(:category, created_at: :desc)

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
                filename: "#{@provider.name.parameterize}-#{@region}-recruitment-performance-report-#{Time.zone.today}.zip",
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
        @exporter ||= RecruitmentPerformanceReportExport.new(
          provider: @provider,
          region: @region,
          provider_report: @provider_report,
          report_type: @report_type,
          edi_reports: @provider_edi_reports,
        ).call
      end

      def set_provider
        @provider ||= Provider.find_by(
          id: params[:support_interface_provider_report]&.fetch(:provider_id, nil),
        ) || Provider.first
      end

      def all_of_england
        ReportSharedEnums.all_of_england_key
      end

      def set_region
        @region = params[:region] || all_of_england
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

      def set_cycle_year
        @recruitment_cycle_year = params.permit(:recruitment_cycle_year)[:recruitment_cycle_year]&.to_i
      end
    end
  end
end
