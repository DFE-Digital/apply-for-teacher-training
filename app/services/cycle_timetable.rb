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

  def self.next_year
    current_year + 1
  end

  def self.previous_year
    current_year - 1
  end

  def self.current_date
    Time.zone.now
  end

  def self.apply_deadline(year = current_year)
    date(:apply_deadline, year)
  end

  def self.reject_by_default(year = current_year)
    date(:reject_by_default, year)
  end

  def self.decline_by_default_date(year = current_year)
    find_closes(year) - 1.day
  end

  def self.find_closes(year = current_year)
    date(:find_closes, year)
  end

  def self.find_opens(year = current_year)
    date(:find_opens, year)
  end

  def self.find_reopens(year = next_year)
    if CYCLE_DATES[year].present?
      date(:find_opens, year)
    else
      date(:find_closes, year - 1) + 8.hours
    end
  end

  def self.apply_opens(year = current_year)
    date(:apply_opens, year)
  end

  def self.apply_reopens(year = next_year)
    if CYCLE_DATES[year].present?
      date(:apply_opens, year)
    else
      find_reopens(year) + 1.week
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

  def self.date(name, year = current_year)
    schedule = real_schedule_for(year)

    schedule.fetch(name)
  end

  #
  # cycle_week methods
  #

  def self.current_cycle_week(time = Time.zone.now)
    weeks = (time.to_date - find_opens(current_year(time)).beginning_of_week.to_date).to_i / 7
    (weeks % 52).succ
  end

  #
  # cycle_schedule methods
  #

  def self.real_schedule_for(year = current_year)
    CYCLE_DATES[year]
  end

  def self.before_apply_opens?
    current_date < date(:apply_opens)
  end

  def self.last_recruitment_cycle_year?(year)
    year == CYCLE_DATES.keys.last
  end

  def self.cycle_year_range(year = current_year)
    "#{year} to #{year + 1}"
  end

  def self.this_day_last_cycle
    days_since_cycle_started = (current_date.to_date - CycleTimetable.apply_opens.to_date).round
    last_cycle_opening_date = apply_opens(previous_year).to_date
    last_cycle_date = days_since_cycle_started.days.after(last_cycle_opening_date)
    DateTime.new(last_cycle_date.year, last_cycle_date.month, last_cycle_date.day, Time.current.hour, Time.current.min, Time.current.sec)
  end

  private_class_method :last_recruitment_cycle_year?
end
