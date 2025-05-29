class GenerateMonthlyStatistics
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :default

  def perform
    return false unless HostingEnvironment.production?
    return false unless monthly_statistics_timetable.generate_today?

    Publications::ITTMonthlyReportGenerator.new(
      generation_date: schedule.generation_date,
      publication_date: schedule.publication_date,
    ).call
  end

private

  def monthly_statistics_timetable
    @monthly_statistics_timetable ||= Publications::MonthlyStatistics::Timetable.new
  end

  def schedule
    @schedule ||= monthly_statistics_timetable.generation_today_schedule
  end
end
