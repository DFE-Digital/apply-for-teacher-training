module Publications
  class NationalRecruitmentPerformanceReport < ApplicationRecord
    validates :cycle_week, :publication_date, presence: true
  end
end
