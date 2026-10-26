module SupportInterface
  class WithdrawalReasonsReportsController < SupportInterfaceController
    before_action :set_provider

    def show
      @withdrawal_reason_report = CandidateWithdrawalReasonsDataByProvider.new(@provider)
    end

  private

    def set_provider
      @provider ||= Provider.find(params.permit(:provider_id)[:provider_id])
    end
  end
end
