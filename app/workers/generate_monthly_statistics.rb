class GenerateMonthlyStatistics < ApplicationJob
  self.queue_adapter = :solid_queue

  retry_on StandardError, attempts: 3

  def perform(force = false, generation_date = nil, publication_date = nil)
    return false unless HostingEnvironment.production?
    return false unless force || monthly_statistics_timetable.generate_today?

    schedule = monthly_statistics_timetable.generation_today_schedule

    Publications::ITTMonthlyReportGenerator.new(
      generation_date: generation_date.presence || schedule&.generation_date || Time.zone.today,
      publication_date: publication_date.presence || schedule&.publication_date || 1.week.from_now,
    ).call
  end

private

  def monthly_statistics_timetable
    @monthly_statistics_timetable ||= Publications::MonthlyStatistics::Timetable.new
  end
end
