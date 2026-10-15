module SupportInterface
  class WithdrawalReasonsReportsController < SupportInterfaceController
    before_action :set_provider

    def show
      @provider_report = ProviderReport.new(provider_id: @provider.id)
      @withdrawal_reason_report = CandidateWithdrawalReasonsDataByProvider.new(@provider)
    end

    def set_provider
      @provider ||= Provider.find_by(
        id: params[:support_interface_provider_report]&.fetch(:provider_id, nil),
      ) || Provider.first
    end
  end
end
