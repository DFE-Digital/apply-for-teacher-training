module Publications
  class ProviderEdiReport < ApplicationRecord
    validates :cycle_week, :category, :publication_date, presence: true
    has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year
    belongs_to :provider

    enum :category, ReportSharedEnums.edi_categories
  end
end
