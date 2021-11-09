module MonthlyStatisticsExportHelper
  def merge_rows_and_totals(data)
    column_names = data[:rows].first.drop(1).map(&:first)
    totals = data[:column_totals]

    data[:rows] + [{ data[:rows].first.keys.first => 'Total' }.merge!(column_names.zip(totals).to_h)]
  end
end
