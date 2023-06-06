module ProviderInterface
  class ReportsController < ProviderInterfaceController
    def index
      @providers = current_user.providers
    end

  private

    def mid_cycle_report_present_for?(provider)
      Publications::ProviderMidCycleReport.exists?(provider: provider)
    end

    helper_method :mid_cycle_report_present_for?
  end
end
