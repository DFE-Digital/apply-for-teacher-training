module DataMigrations
  class BackfillMonthlyStatisticsData
    TIMESTAMP = 20211221113405
    MANUAL_RUN = false

    def change
      reports_with_unset_months = Publications::MonthlyStatistics::MonthlyStatisticsReport.where(month: nil)
      reports_with_unset_months.each do |report|
        created_at_month = report.created_at.month
        generation_date_of_created_at_month = MonthlyStatisticsTimetable::GENERATION_DATES[Date::MONTHNAMES[created_at_month]]
        month = if report.created_at < generation_date_of_created_at_month
                  MonthlyStatisticsTimetable::GENERATION_DATES[Date::MONTHNAMES[created_at_month - 1]]
                else
                  generation_date_of_created_at_month
                end
        report.update(month: month.strftime('%Y-%m'))
      end
    end
  end
end
