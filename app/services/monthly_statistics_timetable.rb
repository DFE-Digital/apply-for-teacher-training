module MonthlyStatisticsTimetable
  # Should the GenerateMonthlyStatistics generate a new report today?
  def self.generate_monthly_statistics?
    # Yes if there is an occurrence today
    Timetable.new.generate_monthly_statistics?
  end

  # Has the report generator run?
  # DetectInvariantsDailyCheck#detect_if_the_monthly_statistics_has_not_run
  # latest_monthly_report.generation_date >= MonthlyStatisticsTimetable.current_generation_date
  #
  # Generation date to use for the new report
  def self.current_generation_date
    # Generation date for most recent occurrence
    Timetable.new.current_month_generation_date
  end

  # Publication date to use for the new report
  def self.current_publication_date
    # Publication date for most recent occurrence
    Timetable.new.current_month_publication_date
  end

  # Not used
  def self.last_generation_date
    Timetable.new.previous_month_generation_date
  end

  # MonthlyStatisticsReport#current_period used to get the previous month if current month is not published
  # DetectInvariantsDailyCheck#detect_if_the_monthly_statistics_has_not_run
  def self.last_publication_date
    return current_publication_date if current_publication_date <= Time.zone.today

    Timetable.new.previous_month_publication_date
  end

  # Not used
  def self.next_generation_date
    Timetable.new.next_month_generation_date
  end

  # MonthlyStatisticsReport#current_period
  # Used to handle non-published reports
  #
  # MonthlyStatisticsPresenter#next_publication_date
  # Used to display the date of the next planned report
  def self.next_publication_date
    return current_publication_date if current_publication_date.past?

    Timetable.new.next_month_publication_date
  end

  def self.third_monday_of_the_month(start_date)
    beginning_of_month = start_date.beginning_of_month
    first_monday = beginning_of_month.upto(beginning_of_month.next_week).find(&:monday?)
    first_monday + 2.weeks
  end

  class Timetable
    attr_reader :base_date

    def initialize(base_date = Time.zone.today)
      @base_date = base_date
    end

    def generate_monthly_statistics?
      base_date == current_month_generation_date
    end

    def current_month_generation_date
      base_date_to_use = base_date

      if base_date.month == 10
        base_date_to_use = base_date.prev_month
      end

      MonthlyStatisticsTimetable.third_monday_of_the_month(base_date_to_use)
    end

    def current_publication_date
      if current_month_publication_date > base_date
        previous_month_publication_date
      else
        current_month_publication_date
      end
    end

    def current_month_publication_date
      current_month_generation_date + 1.week
    end

    def previous_month_generation_date
      Timetable.new(base_date.prev_month).current_month_generation_date
    end

    def previous_month_publication_date
      Timetable.new(base_date.prev_month).current_month_publication_date
    end

    def next_month_generation_date
      if base_date.month == 9
        return Timetable.new(base_date.next_month(2)).current_month_generation_date
      end

      Timetable.new(base_date.next_month).current_month_generation_date
    end

    def next_month_publication_date
      if base_date.month == 9
        return Timetable.new(base_date.next_month(2)).current_month_publication_date
      end

      Timetable.new(base_date.next_month).current_month_publication_date
    end
  end
end
