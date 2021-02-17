
module SupportInterface
  class ExportExport
    def data_for_export
      data_for_export = DataExport::EXPORT_TYPES.values.map do |export|

        export_class = export[:class].new
        export_output = export_class.data_for_export
        columns = export_output[0].keys.map{|x| x.to_s.humanize}

        output = {
            'Name' => export[:name],
        }

        columns_hash = {}
        columns.each_with_index.map do |x, i|
          columns_hash.merge( {i => x})
        end

        output
      end

      # The DataExport class creates the header row for us so we need to ensure
      # we sort by longest hash length to ensure all headers appear
      data_for_export.sort_by(&:length).reverse
    end
  end
end
