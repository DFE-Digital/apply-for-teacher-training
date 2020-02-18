module Integrations
  class PerformanceDashboardController < ApplicationController
    def dashboard
      @statistics = PerformanceStatistics.new
    end
  end
end
