module ProviderInterface
  module Reports
    class RecruitmentPerformanceReportsController < ProviderInterfaceController
      before_action :redirect_if_feature_inactive

      def show
        @provider = current_user.providers.find(provider_id)
        @provider_data = Publications::ProviderRecruitmentPerformanceReport.where(provider: @provider).last&.statistics
        @national_data = Publications::NationalRecruitmentPerformanceReport.last&.statistics
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end

      def redirect_if_feature_inactive
        if FeatureFlag.inactive? :recruitment_performance_report
          redirect_to provider_interface_reports_path
        end
      end
    end
  end
end
