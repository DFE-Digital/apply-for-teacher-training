module ProviderInterface
  module Reports
    class WithdrawalReportsController < ProviderInterfaceController
      attr_reader :provider

      def index
        @providers = current_user.providers
      end

      def show
        @provider = current_user.providers.find(provider_id)
        @withdrawal_report_data = CandidateWithdrawalDataByProvider.new(provider: provider)
        @withdrawal_data = @withdrawal_report_data.withdrawal_data
        @submitted_withdrawal_reason_count = @withdrawal_report_data.submitted_withdrawal_reason_count
      end

    private

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end
    end
  end
end
