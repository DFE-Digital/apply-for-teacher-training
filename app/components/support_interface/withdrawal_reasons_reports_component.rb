module SupportInterface
  class WithdrawalReasonsReportsComponent < ApplicationComponent
    attr_reader :provider_report, :withdrawal_reason_report, :view

    def initialize(provider_report:, withdrawal_reason_report:, view: nil)
      @provider_report = provider_report
      @withdrawal_reason_report = withdrawal_reason_report
      @view = view
    end
  end
end
