module SupportInterface
  class ReasonsForRejectionDashboardComponent < ApplicationComponent
    include ViewHelper

    attr_reader :total_structured_rejection_reasons_count, :total_structured_rejection_reasons_count_this_month,
                :recruitment_cycle_year, :rejection_reasons

    def initialize(rejection_reasons, total_structured_rejection_reasons_count,
                   total_structured_rejection_reasons_count_this_month, recruitment_cycle_year = RecruitmentCycleTimetable.current_year)
      @rejection_reasons = rejection_reasons
      @total_structured_rejection_reasons_count = total_structured_rejection_reasons_count
      @total_structured_rejection_reasons_count_this_month = total_structured_rejection_reasons_count_this_month
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def self.recruitment_cycle_context(recruitment_cycle_year = RecruitmentCycleTimetable.current_year)
      timetable = RecruitmentCycleTimetable.find_by(recruitment_cycle_year:)
      %(#{timetable.cycle_range_name_with_current_indicator} (starts #{recruitment_cycle_year}))
    end

  private

    def sub_reasons_for(reason)
      @rejection_reasons[reason]&.sub_reasons || {}
    end
  end
end
