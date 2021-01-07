module SupportInterface
  class FeatureMetricsDashboardController < SupportInterfaceController
    def dashboard
      @reference_statistics = ReferenceFeatureMetrics.new
      @work_history_statistics = WorkHistoryFeatureMetrics.new
      @reasons_for_rejection_statistics = ReasonsForRejectionFeatureMetrics.new
    end
  end
end
