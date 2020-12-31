module SupportInterface
  class FeatureMetricsDashboardController < SupportInterfaceController
    def dashboard
      @statistics = FeatureMetrics.new
    end
  end
end
