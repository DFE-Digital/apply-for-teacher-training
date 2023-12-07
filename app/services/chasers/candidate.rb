module Chasers
  module Candidate
    # chaser: [days_ago, days_ago]
    OFFER_CHASERS_TO_INTERVALS = {
      offer_10_day: [20, 10],
      offer_20_day: [30, 20],
      offer_30_day: [40, 30],
      offer_40_day: [50, 40],
      offer_50_day: [60, 50],
    }.freeze

    def self.chaser_types
      OFFER_CHASERS_TO_INTERVALS.keys
    end

    def self.chaser_to_date_range
      OFFER_CHASERS_TO_INTERVALS.each_with_object({}) do |(chaser_type, (start, ending)), object|
        object[chaser_type] = (start.days.ago..ending.days.ago)

        yield chaser_type, start.days.ago, ending.days.ago if block_given?
      end
    end
  end
end
