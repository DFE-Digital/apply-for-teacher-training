module SupportInterface
  class ProviderRecruitmentReportsController < SupportInterfaceController
    before_action :set_cycle_year
    before_action :verify_recruitment_cycle
    before_action :set_provider
    before_action :set_region

    def show
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

      @comparison_link = new_support_interface_regional_report_filter_path(
        @provider,
        region: @region,
        recruitment_cycle_year: @recruitment_cycle_year,
      )
      @provider_recruitment_component = ProviderRecruitmentReportsComponent.new(
        statistics: @statistics,
        provider_data: @provider_data,
        provider_report: @provider_report,
        provider_edi_reports: @provider_edi_reports,
        report_type: @report_type,
        provider: @provider,
        region: @region,
        comparison_link: @comparison_link,
        reports_ready: reports_ready?,
      )
    end

  private

    def reports_ready?
      @statistics.present? &&
        @provider_data.present? &&
        @provider_edi_reports.present?
    end

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
      @provider ||= Provider.find(params.permit(:provider_id)[:provider_id])
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
      @latest_report ||= Publications::ProviderRecruitmentPerformanceReport
        .where(provider: @provider, recruitment_cycle_year: @recruitment_cycle_year)
        .order(:cycle_week)
        .last
    end

    def verify_recruitment_cycle
      unless @recruitment_cycle_year == RecruitmentCycleTimetable.current_year ||
             @recruitment_cycle_year == RecruitmentCycleTimetable.previous_year
        redirect_to support_interface_root_path
      end
    end

    def set_cycle_year
      @recruitment_cycle_year ||= params.permit(:recruitment_cycle_year)[:recruitment_cycle_year]&.to_i
    end
  end
end
