module SupportInterface
  class ProviderRecruitmentReportsController < SupportInterfaceController
    before_action :set_provider
    before_action :set_region

    def show
      @provider_report = latest_report.present? ? Publications::ProviderRecruitmentPerformanceReportPresenter.new(latest_report) : nil
      @provider_data = @provider_report&.statistics
      @report_type = @region == all_of_england ? :NATIONAL : :REGIONAL
      @statistics = @region == all_of_england ? national_report&.statistics : regional_report&.statistics

      @provider_edi_reports = Publications::ProviderEdiReport.where(
        provider: @provider,
        cycle_week: @provider_report.cycle_week,
        recruitment_cycle_year: current_timetable.recruitment_cycle_year,
        category: ReportSharedEnums.edi_categories.keys,
      ).select('DISTINCT ON (category) *').order(:category, created_at: :desc).map do |report|
        ProviderEdiReportDecorator.new(report, @region)
      end
    end

  private

    def set_provider
      @provider ||= Provider.find(params.permit(:provider_id)[:provider_id])
    end

    def all_of_england
      Publications::RegionalRecruitmentPerformanceReport.all_of_england_key
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
  end
end
