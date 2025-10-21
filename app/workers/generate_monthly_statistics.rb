class GenerateMonthlyStatistics
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :default

  def perform(force = false)
    return false unless HostingEnvironment.production?
    return false unless force || monthly_statistics_timetable.generate_today?

    schedule = monthly_statistics_timetable.generation_today_schedule

    Publications::ITTMonthlyReportGenerator.new(
      generation_date: schedule.present? ? schedule.generation_date : Time.zone.today,
      publication_date: schedule.present? ? schedule.publication_date : 1.week.from_now,
    ).call
  end

private

  def monthly_statistics_timetable
    @monthly_statistics_timetable ||= Publications::MonthlyStatistics::Timetable.new
  end
end
