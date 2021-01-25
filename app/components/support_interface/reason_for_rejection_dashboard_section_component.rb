module SupportInterface
  class ReasonForRejectionDashboardSectionComponent < ViewComponent::Base
    def initialize(heading:, total_count:, this_month:, percentage_rejected:)
      @heading = heading
      @total_count = total_count
      @this_month = this_month
      @percentage_rejected = percentage_rejected
    end
  end
end
