module SupportInterface
  class FeatureMetricsDashboardController < SupportInterfaceController
    def dashboard
      @reference_statistics = ReferenceFeatureMetrics.new
      @work_history_statistics = WorkHistoryFeatureMetrics.new
      @magic_link_statistics = MagicLinkFeatureMetrics.new
      @reasons_for_rejection_statistics = ReasonsForRejectionFeatureMetrics.new
    end
  end
end
