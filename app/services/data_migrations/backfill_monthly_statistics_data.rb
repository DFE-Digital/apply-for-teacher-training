module DataMigrations
  class BackfillMonthlyStatisticsData
    TIMESTAMP = 20211221113405
    MANUAL_RUN = false

    def change
      reports_with_unset_months = Publications::MonthlyStatistics::MonthlyStatisticsReport.where(month: nil)
      reports_with_unset_months.each do |report|
        report.update(month: report.created_at.strftime('%Y-%m'))
      end
    end
  end
end
