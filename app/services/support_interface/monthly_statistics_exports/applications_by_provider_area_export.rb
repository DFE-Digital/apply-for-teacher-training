module SupportInterface
  module MonthlyStatisticsExports
    class ApplicationsByProviderAreaExport
      include MonthlyStatisticsExportHelper

      def data_for_export(*)
        data = MonthlyStatistics::ByProviderArea.new.table_data
        merge_rows_and_totals(data)
      end
    end
  end
end
