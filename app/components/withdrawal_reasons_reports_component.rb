class WithdrawalReasonsReportsComponent < ApplicationComponent
  attr_reader :withdrawal_reason_report

  def initialize(withdrawal_reason_report:)
    @withdrawal_reason_report = withdrawal_reason_report
  end

  def render?
    withdrawal_reason_report.show_report?
  end
end
