module Publications
  class NationalMidCycleReport < ApplicationRecord
    validates :publication_date, presence: true

    def self.ingest(csv_data, publication_date)
      create(
        publication_date:,
        statistics: csv_data.map(&:to_h),
      )
    end
  end
end
