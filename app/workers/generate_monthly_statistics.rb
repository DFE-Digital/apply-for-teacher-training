class GenerateMonthlyStatistics
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :default

  def perform
    return false unless MonthlyStatisticsTimetable.generate_monthly_statistics?

    dashboard = Publications::MonthlyStatistics::MonthlyStatisticsReport.new(month: MonthlyStatisticsTimetable.month_to_generate_for.strftime('%Y-%m'))
    dashboard.load_table_data
    dashboard.save!
  end
end
