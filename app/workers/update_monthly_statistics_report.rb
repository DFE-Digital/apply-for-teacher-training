class UpdateMonthlyStatisticsReport
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform
    dashboard = MonthlyStatisticsReport.new
    dashboard.load_table_data
    dashboard.save!
  end
end
