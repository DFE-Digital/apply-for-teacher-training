module SupportInterface
  class ReasonForRejectionDashboardSectionComponent < ViewComponent::Base
    def initialize(heading:, total_count:, this_month:, before_this_month:)
      @heading = heading
      @total_count = total_count
      @this_month = this_month
      @before_this_month = before_this_month
    end
  end
end
