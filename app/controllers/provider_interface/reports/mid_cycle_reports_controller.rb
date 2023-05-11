module ProviderInterface
  module Reports
    class MidCycleReportsController < ProviderInterfaceController
      def show
        @provider = current_user.providers.find(provider_id)
        @provider_data = Publications::ProviderMidCycleReport.where(provider_id: provider_id).last.statistics
        @national_data = Publications::NationalMidCycleReport.last.statistics
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end
    end
  end
end
