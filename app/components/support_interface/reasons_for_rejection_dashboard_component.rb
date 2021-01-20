module SupportInterface
  class ReasonsForRejectionDashboardComponent < ViewComponent::Base
    def initialize(rejection_reasons)
      @rejection_reasons = rejection_reasons
    end

    def current_month_rejection_count(reason)
      values = @rejection_reasons.find {|h| h["key"] == reason && h["time_period"] == "this_month" }
      return 0 if values == nil
      values["count"]
    end

    def previous_rejection_count(reason)
      values = @rejection_reasons.find {|h| h["key"] == reason && h["time_period"] == "before_this_month" }
      return 0 if values == nil
      values["count"]
    end

    def total_rejection_count(reason)
      current_month_rejection_count(reason) + previous_rejection_count(reason)
    end
  end
end
