module SupportInterface
  module MonthlyStatisticsExports
    class ApplicationsByProviderAreaExport
      include MonthlyStatisticsExportHelper

      def data_for_export(*)
        data = Publications::MonthlyStatistics::ByProviderArea.new.table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
