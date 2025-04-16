class CycleTimetable
  # These dates are configuration for when the previous cycle ends and the next cycle starts

  def self.current_year(now = Time.zone.now)
    CYCLE_DATES.keys.detect do |year|
      return year if last_recruitment_cycle_year?(year)

      start = CYCLE_DATES[year][:find_opens]
      ending = CYCLE_DATES[year + 1][:find_opens]

      now.between?(start, ending)
    end
  end

  def self.holidays(year = current_year)
    # do not support the cycle switcher via #date as:
    #
    # a) fake schedules do not deal with timespans long enough for holidays
    # b) looking up SiteSetting.cycle_schedule requires a database, which we
    # don’t want (or necessarily have, in builds) at boot time when the
    # business_time initializer calls this code
    real_schedule_for(year).fetch(:holidays)
  end

  def self.real_schedule_for(year = current_year)
    CYCLE_DATES[year]
  end

  def self.last_recruitment_cycle_year?(year)
    year == CYCLE_DATES.keys.last
  end

  private_class_method :last_recruitment_cycle_year?
end
