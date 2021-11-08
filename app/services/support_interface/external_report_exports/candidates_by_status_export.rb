module SupportInterface
  module ExternalReportExports
    class CandidatesByStatusExport
      include ExternalReportExportHelper

      def data_for_export(*)
        data = MonthlyStatistics::ByStatus.new(by_candidate: true).table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
