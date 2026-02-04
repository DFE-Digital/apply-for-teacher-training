module Publications
  class RegionalRecruitmentPerformanceReport < ApplicationRecord
    ALL_REGIONS = 'all'.freeze

    validates :cycle_week, :region, :publication_date, presence: true
    has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year

    def self.select_options
      result = Publications::RegionalRecruitmentPerformanceReport.regions.each.map do |key, value|
        [value, key]
      end
      result.prepend(['All of England', ALL_REGIONS])
      result
    end

    enum :region, {
      west_midlands: 'West Midlands (England)',
      north_west: 'North West (England)',
      london: 'London',
      nort_east: 'North East (England)',
      south_west: 'South West (England)',
      east_midlands: 'East Midlands (England)',
      east_of_england: 'East of England',
      yorkshire_and_the_humber: 'Yorkshire and The Humber',
      south_east: 'South East (England)',
    }
  end
end
