module Publications
  class ProviderRecruitmentPerformanceReport < ApplicationRecord
    belongs_to :provider
    validates :cycle_week, :publication_date, presence: true

    def reporting_end_date
      CycleTimetable.cycle_week_date_range(cycle_week).last.to_date
    end
  end
end
