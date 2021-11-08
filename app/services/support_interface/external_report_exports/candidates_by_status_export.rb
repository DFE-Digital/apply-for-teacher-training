module SupportInterface
  module ExternalReportExports
    class CandidatesByStatusExport
      def data_for_export(*)
        data = MonthlyStatistics::ByStatus.new(by_candidate: true).table_data
        merge_rows_and_totals(data)
      end

      def merge_rows_and_totals(data)
        totals = data[:column_totals]

        data[:rows] + [
          {
            'Status' => 'Total',
            'First application' => totals[0],
            'Apply again' => totals[1],
            'Total' => totals[2],
          },
        ]
      end
    end
  end
end
