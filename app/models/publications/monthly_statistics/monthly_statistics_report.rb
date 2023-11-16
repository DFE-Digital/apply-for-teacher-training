module Publications
  module MonthlyStatistics
    class MonthlyStatisticsReport < ApplicationRecord
      validates :statistics, :generation_date, :publication_date, :month, presence: true
    end
  end
end
