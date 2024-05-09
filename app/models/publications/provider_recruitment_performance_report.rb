module Publications
  class ProviderRecruitmentPerformanceReport < ApplicationRecord
    belongs_to :provider
    validates :cycle_week, :publication_date, presence: true
  end
end
