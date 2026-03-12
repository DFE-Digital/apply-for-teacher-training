module Publications
  class NationalRecruitmentPerformanceReport < ApplicationRecord
    validates :cycle_week, :publication_date, presence: true
    has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year

    def self.last_in_year(recruitment_cycle_year)
      joins(:recruitment_cycle_timetable).where(
        recruitment_cycle_timetable: { recruitment_cycle_year: },
      ).order(:cycle_week).last
    end
  end
end
