module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index
      @statistics = PerformanceStatistics.new
    end
  end
end
