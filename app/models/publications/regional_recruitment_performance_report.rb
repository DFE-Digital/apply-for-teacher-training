module Publications
  class RegionalRecruitmentPerformanceReport < ApplicationRecord
    validates :cycle_week, :region, :publication_date, presence: true
    has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year

    enum :region, ReportSharedEnums.england_regions
  end
end
