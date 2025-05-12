module Publications
  class ProviderRecruitmentPerformanceReport < ApplicationRecord
    belongs_to :provider
    validates :cycle_week, :publication_date, presence: true
    has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year

    def reporting_end_date
      recruitment_cycle_timetable.cycle_week_date_range(cycle_week).last.to_date
    end

    def previous_cycle?
      recruitment_cycle_year < RecruitmentCycleTimetable.current_year
    end
  end
end
