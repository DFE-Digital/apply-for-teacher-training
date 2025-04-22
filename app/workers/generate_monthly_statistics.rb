class GenerateMonthlyStatistics
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :default

  def perform
    return false unless HostingEnvironment.production?
    return false unless MonthlyStatisticsTimetable.generate_monthly_statistics?

    Publications::ITTMonthlyReportGenerator.new(
      generation_date:,
      publication_date:,
    ).call
  end

private

  def generation_date
    MonthlyStatisticsTimetable.current_generation_date
  end

  def publication_date
    MonthlyStatisticsTimetable.current_publication_date
  end
end
