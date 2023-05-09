module Publications
  class ProviderMidCycleReport < ApplicationRecord
    belongs_to :provider
    validates :publication_date, presence: true

    def self.ingest(csv_data, publication_date)
      csv_data
        .map(&:to_h)
        .group_by { |h| h['provider_id'] }
        .each do |provider_id, provider_data|
          next unless Provider.find_by(id: provider_id)

          create(
            provider_id:,
            publication_date:,
            statistics: provider_data,
          )
        end
    end
  end
end
