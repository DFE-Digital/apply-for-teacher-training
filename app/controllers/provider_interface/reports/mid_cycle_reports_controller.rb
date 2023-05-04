module ProviderInterface
  module Reports
    class MidCycleReportsController < ProviderInterfaceController
      include CSVNameHelper

      def show
        @provider = current_user.providers.find(provider_id)
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end
    end
  end
end
