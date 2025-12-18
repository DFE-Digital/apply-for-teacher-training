module SupportInterface
  class ProviderRecruitmentPerformanceReportsController < SupportInterfaceController
    def show
      @provider = Provider.find(provider_id)
      @provider_report = latest_report.present? ? Publications::ProviderRecruitmentPerformanceReportPresenter.new(latest_report) : nil

      @provider_data = @provider_report&.statistics
      @national_data = national_report&.statistics
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
