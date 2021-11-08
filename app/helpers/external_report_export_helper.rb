module ExternalReportExportHelper
  def merge_rows_and_totals(data)
    hash = data[:rows].first.drop(1)
    totals = data[:column_totals]

    data[:rows] + [{ data[:rows].first.keys.first => 'Total' }.merge!(merge_totals(hash, totals).to_h)]
  end

private

  def merge_totals(hash, totals)
    hash.map do |key, _value|
      [key, totals[hash.find_index { |k, _v| k == key }]]
    end
  end
end
