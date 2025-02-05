module Publications
  class NationalRecruitmentPerformanceReport < ApplicationRecord
    validates :cycle_week, :publication_date, presence: true
    has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year
  end
end
