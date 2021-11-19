module SupportInterface
  module MonthlyStatisticsExports
    class ApplicationsByCourseTypeExport
      include MonthlyStatisticsExportHelper

      def data_for_export(*)
        data = Publications::MonthlyStatistics::ByCourseType.new.table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
