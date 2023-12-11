module Chasers
  module Candidate
    # chaser: days_ago
    OFFER_CHASERS = {
      offer_10_day: 10,
      offer_20_day: 20,
      offer_30_day: 30,
      offer_40_day: 40,
      offer_50_day: 50,
    }.freeze

    def self.chaser_types
      OFFER_CHASERS.keys
    end

    def self.chaser_to_date_range
      OFFER_CHASERS.transform_values do |day|
        day.days.ago.all_day
      end
    end
  end
end
