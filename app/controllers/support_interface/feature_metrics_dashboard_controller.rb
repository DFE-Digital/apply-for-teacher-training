module SupportInterface
  class FeatureMetricsDashboardController < SupportInterfaceController
    def dashboard
      @reference_statistics = ReferenceFeatureMetrics.new
      @work_history_statistics = WorkHistoryFeatureMetrics.new
    end
  end
end
