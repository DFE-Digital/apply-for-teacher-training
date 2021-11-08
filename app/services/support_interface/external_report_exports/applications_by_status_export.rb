module SupportInterface
  module ExternalReportExports
    class ApplicationsByStatusExport
      include ExternalReportExportHelper

      def data_for_export(*)
        data = MonthlyStatistics::ByStatus.new(by_candidate: false).table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
