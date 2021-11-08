module SupportInterface
  module ExternalReportExports
    class CandidatesByStatusExport
      def data_for_export(*)
        data = MonthlyStatistics::ByStatus.new(by_candidate: true).table_data
        merge_rows_and_totals(data)
      end

      def merge_rows_and_totals(data)
        keys = data[:rows].first.reject { |key, _value| key == 'Status' }
        totals = data[:column_totals]

        data[:rows] + [ { 'Status' => 'Total' }.merge!(merge_totals(keys, totals).to_h)]
      end

      def merge_totals(hash, totals)
        hash.map do |key, _value|
          [key, totals[hash.find_index { |k, _v| k == key }]]
        end
      end
    end
  end
end
