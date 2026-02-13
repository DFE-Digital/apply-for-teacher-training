module Publications
  class RegionalEdiReport < ApplicationRecord
    validates :cycle_week, :region, :category, :publication_date, presence: true
    has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year

    enum :region, ReportSharedEnums.england_regions_including_england
    enum :category, ReportSharedEnums.edi_categories
  end
end
