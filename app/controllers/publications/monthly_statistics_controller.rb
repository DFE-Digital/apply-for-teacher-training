module Publications
  class MonthlyStatisticsController < ApplicationController
    before_action :redirect_unless_published

    def show
      @monthly_statistics_report = MonthlyStatisticsTimetable.current_report
      @statistics = @monthly_statistics_report.statistics
      @academic_year_name = RecruitmentCycle.cycle_name(CycleTimetable.next_year)
      @current_cycle_name = RecruitmentCycle.verbose_cycle_name
      @exports = MonthlyStatisticsTimetable.current_exports
    end

    def redirect_unless_published
      redirect_to root_path unless FeatureFlag.active?(:publish_monthly_statistics)
    end
  end
end
