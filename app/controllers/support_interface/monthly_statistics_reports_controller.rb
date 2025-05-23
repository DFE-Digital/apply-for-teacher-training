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
  end
end
