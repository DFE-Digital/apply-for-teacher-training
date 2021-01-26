module SupportInterface
  class ReasonsForRejectionDashboardComponent < ViewComponent::Base
    include ViewHelper
    def initialize(rejection_reasons)
      @rejection_reasons = rejection_reasons
    end

    def current_month_rejection_count(reason)
      values = @rejection_reasons.find { |h| h['key'] == reason && h['time_period'] == 'this_month' }
      return 0 if values.nil?

      values['count']
    end

    def total_rejection_count(reason)
      current_month_rejection_count(reason) + previous_rejection_count(reason)
    end

    def percentage_rejected_for_reason(reason)
      count = current_month_rejection_count(reason) + previous_rejection_count(reason)
      total = @rejection_reasons.inject(0) { |sum, hash| sum + hash['count'] }
      formatted_percentage(count, total)
    end

  private

    def previous_rejection_count(reason)
      values = @rejection_reasons.find { |h| h['key'] == reason && h['time_period'] == 'before_this_month' }
      return 0 if values.nil?

      values['count']
    end

    def formatted_percentage(count, total)
      percentage = percent_of(count, total)
      precision = (percentage % 1).zero? ? 0 : 2
      number_to_percentage(percentage, precision: precision)
    end
  end
end
