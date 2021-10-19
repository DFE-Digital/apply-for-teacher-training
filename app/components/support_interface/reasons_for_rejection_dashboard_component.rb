module SupportInterface
  class ReasonsForRejectionDashboardComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :total_structured_rejection_reasons_count

    def initialize(rejection_reasons, total_structured_rejection_reasons_count)
      @rejection_reasons = rejection_reasons
      @total_structured_rejection_reasons_count = total_structured_rejection_reasons_count
    end

  private

    def current_month_rejection_count(reason)
      @rejection_reasons[reason]&.this_month || 0
    end

    def total_rejection_count(reason)
      @rejection_reasons[reason]&.all_time || 0
    end

    def percentage_rejected_for_reason(reason)
      formatted_percentage(total_rejection_count(reason), total_structured_rejection_reasons_count)
    end

    def sub_reasons_for(reason)
      @rejection_reasons[reason]&.sub_reasons || {}
    end

    def previous_rejection_count(reason)
      total_rejection_count(reason) - current_month_rejection_count(reason)
    end
  end
end
