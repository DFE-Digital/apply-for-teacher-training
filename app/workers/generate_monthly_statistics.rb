class GenerateMonthlyStatistics
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :default

  def perform
    return false unless MonthlyStatisticsTimetable.generate_monthly_statistics?

    dashboard = Publications::MonthlyStatistics::MonthlyStatisticsReport.new
    dashboard.load_table_data
    dashboard.save!
  end
end
