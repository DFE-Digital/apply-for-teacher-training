module ProviderInterface
  module Reports
    class RecruitmentPerformanceReportsController < ProviderInterfaceController
      def show
        @provider = current_user.providers.find(provider_id)
        report = Publications::ProviderRecruitmentPerformanceReport.where(provider: @provider).order(:cycle_week).last
        @provider_report = report.present? ? Publications::ProviderRecruitmentPerformanceReportPresenter.new(report) : nil

        @provider_data = @provider_report&.statistics
        @national_data = national_report&.statistics
      end

    private

      def national_report
        if @provider_report.present?
          @national_report ||=
            Publications::NationalRecruitmentPerformanceReport.where(
              cycle_week: @provider_report.cycle_week,
            ).last
        end
      end

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end
    end
  end
end
