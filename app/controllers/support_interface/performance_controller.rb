require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def course_statistics; end

    def course_options
      @course_options = CourseOption.where('vacancy_status != ?', 'vacancies').includes(:course, :site)
    end

    def dashboard
      raise ArgumentError unless params[:year].in?([nil, '2020', '2021'])

      @statistics = PerformanceStatistics.new(params[:year])
    end

    def feature_metrics
      @reference_statistics = ReferenceFeatureMetrics.new
      @work_history_statistics = WorkHistoryFeatureMetrics.new
      @magic_link_statistics = MagicLinkFeatureMetrics.new
      @reasons_for_rejection_statistics = ReasonsForRejectionFeatureMetrics.new
    end

    def reasons_for_rejection
      @reasons_for_rejection = GetReasonsForRejectionFromApplicationChoices.new.reason_counts
    end

    def unavailable_choices
      @monitor = SupportInterface::ApplicationMonitor.new
    end

    def ucas_matches_statistics; end
  end
end
