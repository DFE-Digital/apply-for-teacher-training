class MonthlyStatisticsController < ApplicationController
  def show
    @statistics = MonthlyStatisticsReport.last.statistics
  end
end
