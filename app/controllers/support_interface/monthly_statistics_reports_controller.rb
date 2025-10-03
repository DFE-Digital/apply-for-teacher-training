module SupportInterface
  class MonthlyStatisticsReportsController < SupportInterfaceController
    def index
      @monthly_statistics_reports = ::Publications::MonthlyStatistics::MonthlyStatisticsReport.order(publication_date: :desc)
    end

    def show
      @report = Publications::MonthlyStatistics::MonthlyStatisticsReport.find(params[:id])

      @presenter = if @report.v2?
                     @presenter = Publications::V2::MonthlyStatisticsPresenter.new(@report)
                   else
                     @presenter = Publications::V1::MonthlyStatisticsPresenter.new(@report)
                     @csv_export_types_and_sizes = MonthlyStatistics::V1::CalculateDownloadSizes.new(@report).call
                   end
    end

  private

    def show_report_not_generated_warning?
      latest_past_generation_date.present? &&
        Publications::MonthlyStatistics::MonthlyStatisticsReport.find_by(
          generation_date: latest_past_generation_date,
        ).blank?
    end
    helper_method :show_report_not_generated_warning?

    def latest_past_generation_date
      @latest_past_generation_date ||= Publications::MonthlyStatistics::Timetable
        .new
        .generated_schedules
        .last
        &.generation_date
    end
    helper_method :latest_past_generation_date
  end
end
