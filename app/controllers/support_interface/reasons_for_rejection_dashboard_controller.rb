module SupportInterface
  class ReasonsForRejectionDashboardController < SupportInterfaceController
    def dashboard
      @reasons_for_rejection_statistics = ReasonsForRejectionFeatureMetrics.new
    end
  end
end
