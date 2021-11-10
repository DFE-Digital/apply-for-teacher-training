module SupportInterface
  module MonthlyStatisticsExports
    class ApplicationsByPrimarySpecialistSubjectExport
      include MonthlyStatisticsExportHelper

      def data_for_export(*)
        data = MonthlyStatistics::ByPrimarySpecialistSubject.new.table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
