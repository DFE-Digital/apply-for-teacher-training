module SupportInterface
  module MonthlyStatisticsExports
    class CandidatesBySexExport
      include MonthlyStatisticsExportHelper

      def data_for_export(*)
        data = MonthlyStatistics::BySex.new.table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
