module SupportInterface
  class ReasonsForRejectionDashboardComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :total_structured_rejection_reasons_count, :total_structured_rejection_reasons_count_this_month,
                :recruitment_cycle_year, :rejection_reasons

    def initialize(rejection_reasons, total_structured_rejection_reasons_count,
                   total_structured_rejection_reasons_count_this_month, recruitment_cycle_year = RecruitmentCycle.current_year)
      @rejection_reasons = rejection_reasons
      @total_structured_rejection_reasons_count = total_structured_rejection_reasons_count
      @total_structured_rejection_reasons_count_this_month = total_structured_rejection_reasons_count_this_month
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def self.recruitment_cycle_context(recruitment_cycle_year = RecruitmentCycle.current_year)
      text = %(#{RecruitmentCycle.cycle_name(recruitment_cycle_year)} (starts #{recruitment_cycle_year}))
      text += ' - current' if recruitment_cycle_year == RecruitmentCycle.current_year
      text
    end

  private

    def sub_reasons_for(reason)
      @rejection_reasons[reason]&.sub_reasons || {}
    end
  end
end
