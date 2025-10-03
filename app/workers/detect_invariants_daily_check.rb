# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariantsDailyCheck
  include Sidekiq::Worker

  def perform
    detect_if_the_monthly_statistics_has_not_run
  end

  def detect_if_the_monthly_statistics_has_not_run
    return unless HostingEnvironment.production?

    latest_past_generation_date = Publications::MonthlyStatistics::Timetable
                                           .new
                                           .generated_schedules
                                           .last
                                            &.generation_date

    return if latest_past_generation_date.nil? # We don't have any generation dates in the past.

    report = Publications::MonthlyStatistics::MonthlyStatisticsReport.find_by(
      generation_date: latest_past_generation_date,
    )

    if report.blank?
      message = "The monthly statistics report has not been generated for #{latest_past_generation_date.to_date.strftime('%B')}"
      Sentry.capture_exception(MonthlyStatisticsReportHasNotRun.new(message))
    end
  end

  class MonthlyStatisticsReportHasNotRun < StandardError; end

private

  def helpers
    Rails.application.routes.url_helpers
  end
end
