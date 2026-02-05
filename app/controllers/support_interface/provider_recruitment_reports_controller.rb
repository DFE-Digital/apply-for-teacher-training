module SupportInterface
  class ProviderRecruitmentReportsController < SupportInterfaceController
    def show
      @provider = Provider.find(provider_id)
      @provider_report = latest_report.present? ? Publications::ProviderRecruitmentPerformanceReportPresenter.new(latest_report) : nil
      @provider_data = @provider_report&.statistics

      all_of_england = Publications::RegionalRecruitmentPerformanceReport::ALL_REGIONS
      @region = params[:region] || all_of_england
      @report_type = @region == all_of_england ? :NATIONAL : :REGIONAL
      @statistics = @region == all_of_england ? national_report&.statistics : regional_report&.statistics

      @disability_data = ProviderInterface::DiversityDataByProvider.new(
        provider: Provider.find(11),
        recruitment_cycle_year: 2026,
      ).disability_data
    end

  private

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

    def provider_id
      params.permit(:provider_id)[:provider_id]
    end
  end
end
