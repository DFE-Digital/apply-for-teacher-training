module Chasers
  module Candidate
    # chaser: [days_ago, days_ago]
    OFFER_CHASERS_TO_INTERVALS = {
      offer_10_day: [19, 10],
      offer_20_day: [29, 20],
      offer_30_day: [39, 30],
      offer_40_day: [49, 40],
      offer_50_day: [59, 50],
    }.freeze

    def self.chaser_types
      OFFER_CHASERS_TO_INTERVALS.keys
    end

    def self.chaser_to_date_range
      OFFER_CHASERS_TO_INTERVALS.each_with_object({}) do |(chaser_type, (start, ending)), object|
        object[chaser_type] = (start.days.ago..ending.days.ago)
      end
    end
  end
end
