module SupportInterface
  class ReasonsForRejectionDashboardComponent < ViewComponent::Base
    include ViewHelper
    def initialize(rejection_reasons)
      @rejection_reasons = rejection_reasons
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

    def total_structured_rejection_reasons_count
      @total_structured_rejection_reasons_count ||= ApplicationChoice.where.not(structured_rejection_reasons: nil).count
    end

    def sub_reasons_for(reason)
      @rejection_reasons[reason]&.sub_reasons || {}
    end

    def previous_rejection_count(reason)
      total_rejection_count(reason) - current_month_rejection_count(reason)
    end

    def formatted_percentage(count, total)
      percentage = percent_of(count, total)
      precision = (percentage % 1).zero? ? 0 : 2
      number_to_percentage(percentage, precision: precision)
    end
  end
end
