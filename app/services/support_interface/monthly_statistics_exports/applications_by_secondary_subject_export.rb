module SupportInterface
  module MonthlyStatisticsExports
    class ApplicationsBySecondarySubjectExport
      include MonthlyStatisticsExportHelper

      def data_for_export(*)
        data = MonthlyStatistics::BySecondarySubject.new.table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
