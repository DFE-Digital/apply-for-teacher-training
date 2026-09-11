# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariantsDailyCheck < ApplicationJob
  def perform
    detect_if_the_monthly_statistics_has_not_run

    detect_unconfirmed_vendors
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
      report = Publications::MonthlyStatistics::MonthlyStatisticsReport.find_by(
        month: latest_past_generation_date.strftime('%Y-%m'),
      ) # was the report generated on a different date for this month?
    end

    if report.blank?
      message = "The monthly statistics report has not been generated for #{latest_past_generation_date.to_date.strftime('%B')}"
      Sentry.capture_exception(MonthlyStatisticsReportHasNotRun.new(message))
    end
  end

  def detect_unconfirmed_vendors
    return unless HostingEnvironment.production? || HostingEnvironment.sandbox_mode?

    unconfirmed_vendors = Vendor.unconfirmed.where.not(name: 'in_house').ids

    if unconfirmed_vendors.any?
      Sentry.capture_exception(
        UnconfirmedVendorsError.new(
          "The vendors with ids #{unconfirmed_vendors} have been created by providers, we need to confirm if they are real vendors",
        ),
      )
    end
  end

  class MonthlyStatisticsReportHasNotRun < StandardError; end
  class UnconfirmedVendorsError < StandardError; end

private

  def helpers
    Rails.application.routes.url_helpers
  end
end
