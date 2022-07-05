module MonthlyStatisticsTimetable
  def self.generate_monthly_statistics?
    Time.zone.today == generation_date
  end

  def self.generation_date
    third_monday_of_the_month(Date.current.beginning_of_month)
  end

  def self.last_months_generation_date
    third_monday_of_the_month(Date.current.beginning_of_month - 1.month)
  end

  def self.publish_date
    generation_date + 1.week
  end

  def self.last_months_publish_date
    last_months_generation_date + 1.week
  end

  def self.report_for_current_period
    if publish_date > Time.zone.today
      report_for(last_months_publish_date.strftime('%Y-%m'))
    else
      report_for(publish_date.strftime('%Y-%m'))
    end
  end

  def self.report_for(month)
    Publications::MonthlyStatistics::MonthlyStatisticsReport.where(month: month).order(created_at: :desc).first!
  end

  def self.third_monday_of_the_month(start_date)
    first_monday = start_date.upto(start_date.next_week).find(&:monday?)
    first_monday + 2.weeks
  end
end
