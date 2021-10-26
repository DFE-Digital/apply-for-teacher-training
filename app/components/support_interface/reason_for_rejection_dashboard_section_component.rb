module SupportInterface
  class ReasonForRejectionDashboardSectionComponent < ViewComponent::Base
    include ViewHelper

    def initialize(heading:, total_count:, this_month:, percentage_rejected:, total_rejection_count:,
                   total_rejection_count_this_month:, reason_key:, sub_reasons_result: nil,
                   recruitment_cycle_year: RecruitmentCycle.current_year)
      @heading = heading
      @total_count = total_count
      @this_month = this_month
      @percentage_rejected = percentage_rejected
      @total_rejection_count = total_rejection_count
      @total_rejection_count_this_month = total_rejection_count_this_month
      @reason_key = reason_key
      @sub_reasons_result = ordered_sub_reason_results(sub_reasons_result) if sub_reasons_result.present?
      @recruitment_cycle_year = recruitment_cycle_year
    end

  private

    def ordered_sub_reason_results(sub_reasons_result)
      sub_reasons_result.slice(*ReasonsForRejectionCountQuery::SUBREASON_VALUES[@reason_key].map(&:to_s))
    end

    def number_of_rejections_out_of_total_rejections
      "#{@total_count} of #{@total_rejection_count} application choices"
    end
  end
end
