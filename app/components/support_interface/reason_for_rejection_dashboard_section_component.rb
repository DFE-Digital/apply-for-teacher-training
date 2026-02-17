module SupportInterface
  class ReasonForRejectionDashboardSectionComponent < ApplicationComponent
    include ViewHelper

    def initialize(heading:, rejection_reasons:, total_rejection_count:, total_rejection_count_this_month:,
                   reason_key:, sub_reasons_result: nil, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
      @heading = heading
      @rejection_reasons = rejection_reasons
      @total_rejection_count = total_rejection_count
      @total_rejection_count_this_month = total_rejection_count_this_month
      @reason_key = reason_key
      @sub_reasons_result = sub_reasons_result if sub_reasons_result.present?
      @recruitment_cycle_year = recruitment_cycle_year
    end

  private

    def current_cycle?
      @recruitment_cycle_year == RecruitmentCycleTimetable.current_year
    end

    def rejection_count(time_period = :all_time)
      @rejection_reasons[@reason_key].send(time_period) || 0
    end

    def percentage_rejected_for_reason
      formatted_percentage(rejection_count, @total_rejection_count)
    end

    def percentage_rejected_for_reason_this_month
      formatted_percentage(rejection_count(:this_month), @total_rejection_count_this_month)
    end

    def number_of_rejections_out_of_total_rejections
      "#{rejection_count} of #{@total_rejection_count} rejections included this category"
    end

    def number_of_rejections_out_of_total_this_month
      "#{rejection_count(:this_month)} of #{@total_rejection_count_this_month} rejections in #{Time.zone.now.strftime('%B')} included this category"
    end
  end
end
