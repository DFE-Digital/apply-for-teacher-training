module Publications
  class MonthlyStatisticsController < ApplicationController
    before_action :redirect_unless_published

    def show
      @presenter = Publications::MonthlyStatisticsPresenter.new(MonthlyStatisticsTimetable.current_report)
    end

    def redirect_unless_published
      redirect_to root_path unless FeatureFlag.active?(:publish_monthly_statistics)
    end
  end
end
