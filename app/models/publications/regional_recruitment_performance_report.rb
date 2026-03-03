module Publications
  class RegionalRecruitmentPerformanceReport < ApplicationRecord
    validates :cycle_week, :region, :publication_date, presence: true
    has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year

    enum :region, {
      west_midlands: 'West Midlands (England)',
      north_west: 'North West (England)',
      london: 'London',
      north_east: 'North East (England)',
      south_west: 'South West (England)',
      east_midlands: 'East Midlands (England)',
      east_of_england: 'East (England)',
      yorkshire_and_the_humber: 'Yorkshire and The Humber',
      south_east: 'South East (England)',
    } # if you add/remove one think about RegionReportFilter

    def self.all_of_england_key
      'all_of_england'
    end

    def self.all_of_england_value
      'All of England'
    end
  end
end
