class FeatureMetricsDashboard < ApplicationRecord
  def load_updated_metrics
    dashboard.avg_time_to_get_references = reference_statistics.average_time_to_get_references(
      EndOfCycleTimetable.apply_reopens.beginning_of_day,
    )
    dashboard.avg_time_to_get_references_this_month = reference_statistics.average_time_to_get_references(
      Time.zone.now.beginning_of_month,
    )
    dashboard.avg_time_to_get_references_last_month = reference_statistics.average_time_to_get_references(
      Time.zone.now.beginning_of_month - 1.month,
      Time.zone.now.beginning_of_month,
    )

    # and so on, for all columns
  end

private

  def reference_statistics
    ReferenceFeatureMetrics.new
  end

  def work_history_statistics
    WorkHistoryFeatureMetrics.new
  end

  def magic_link_statistics
    MagicLinkFeatureMetrics.new
  end

  def reasons_for_rejection_statistics
    ReasonsForRejectionFeatureMetrics.new
  end
end
