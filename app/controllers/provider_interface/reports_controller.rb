module ProviderInterface
  class ReportsController < ProviderInterfaceController
    def index
      @providers = current_user.providers.preload(:performance_reports)
      @performance_reports = current_user.providers.any? { _1.performance_reports.present? }
    end
  end
end
