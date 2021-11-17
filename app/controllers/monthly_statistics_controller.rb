class MonthlyStatisticsController < ApplicationController
  def show
    @monthly_statistics_report = MonthlyStatisticsReport.latest_publishable_report
    @statistics = @monthly_statistics_report.statistics
    @academic_year_name = RecruitmentCycle.cycle_name(CycleTimetable.next_year)
    @current_cycle_name = RecruitmentCycle.verbose_cycle_name
    @exports = MonthlyStatisticsReport.latest_publishable_exports
  end
end
