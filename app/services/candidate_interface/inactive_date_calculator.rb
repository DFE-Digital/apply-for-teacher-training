module CandidateInterface
  class InactiveDateCalculator
    STANDARD_DAYS_UNTIL_INACTIVE = 30

    attr_reader :reject_by_default_date

    def initialize(effective_date:, reject_by_default_date:)
      @effective_date = effective_date.end_of_day
      @reject_by_default_date = reject_by_default_date
    end

    def inactive_date
      [
        STANDARD_DAYS_UNTIL_INACTIVE.business_days.after(@effective_date).end_of_day,
        reject_by_default_date,
      ].min
    end

    def inactive_days
      # number of business days between the effective date and inactive date
      # (will be 30, or the number of days usually, but less as we approach reject by default at)
      date = @effective_date.to_datetime.business_days_until inactive_date
      # if we've changed time zones, we need to subtract a date
      inactive_date.zone == @effective_date.zone ? date : date - 1
    end
  end
end
