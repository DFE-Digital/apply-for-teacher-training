module SupportInterface
  class PerformanceController < SupportInterfaceController
    skip_before_action :authenticate_support_user!, only: :index

    def index
      @statistics = PerformanceStatistics.new
    end
  end
end
