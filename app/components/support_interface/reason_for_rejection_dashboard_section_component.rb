module SupportInterface
  class ReasonForRejectionDashboardSectionComponent < ViewComponent::Base
    def initialize(heading:, total_count:, this_month:, percentage_rejected:, total_structured_rejection_reasons_count:, sub_reasons_key: nil, sub_reasons_result: nil)
      @heading = heading
      @total_count = total_count
      @this_month = this_month
      @percentage_rejected = percentage_rejected
      @total_structured_rejection_reasons_count = total_structured_rejection_reasons_count
      @sub_reasons_key = sub_reasons_key
      @sub_reasons_result = sub_reasons_result
    end

  private

    def number_of_rejections_out_of_total_rejections
      "#{@total_count} of #{@total_structured_rejection_reasons_count} application choices"
    end
  end
end
