module SupportInterface
  class MonthlyStatisticsReportsController < SupportInterfaceController
    def index
      @monthly_statistics_reports = ::Publications::MonthlyStatistics::MonthlyStatisticsReport.order(publication_date: :desc)
    end
  end
end
