module ProviderInterface
  module Reports
    class WithdrawalReasonsReportsController < ProviderInterfaceController
      attr_reader :provider

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
