module SupportInterface
  module MonthlyStatisticsExports
    class CandidatesByAgeGroupExport
      include MonthlyStatisticsExportHelper

      def data_for_export(*)
        data = MonthlyStatistics::ByAgeGroup.new.table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
