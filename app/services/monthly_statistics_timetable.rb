module MonthlyStatisticsTimetable
  def self.generate_monthly_statistics?
    Time.zone.today == current_generation_date
  end

  def self.current_generation_date
    third_monday_of_the_month(Date.current.beginning_of_month)
  end

  def self.current_publication_date
    current_generation_date + 1.week
  end

  def self.last_generation_date
    third_monday_of_the_month(Date.current.beginning_of_month - 1.month)
  end

  def self.last_publication_date
    return current_publication_date if current_publication_date <= Time.zone.today

    last_generation_date + 1.week
  end

  def self.next_generation_date
    third_monday_of_the_month(Date.current.beginning_of_month + 1.month)
  end

  def self.next_publication_date
    return current_publication_date if current_publication_date > Time.zone.today

    next_generation_date + 1.week
  end

  def self.report_for_current_period
    if next_publication_date > Time.zone.today
      current_report_at(last_publication_date)
    else
      current_report_at(Time.zone.today)
    end
  end

  def self.current_report_at(date)
    month = date.strftime('%Y-%m')
    Publications::MonthlyStatistics::MonthlyStatisticsReport
      .where(month: month)
      .order(created_at: :desc)
      .first!
  end

  def self.third_monday_of_the_month(start_date)
    first_monday = start_date.upto(start_date.next_week).find(&:monday?)
    first_monday + 2.weeks
  end
end
