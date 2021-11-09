module SupportInterface
  module MonthlyStatisticsExports
    class ApplicationsByCourseAgeGroupExport
      include MonthlyStatisticsExportHelper

      def data_for_export(*)
        data = MonthlyStatistics::ByCourseAgeGroup.new.table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
