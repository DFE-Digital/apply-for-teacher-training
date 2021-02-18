module SupportInterface
  class DocsController < SupportInterfaceController
    def index
        exports = DataExport::EXPORT_TYPES.except(:export_export)
        data_for_export = exports.values.map do |export|

          export_class = export[:class].new
          export_output = export_class.data_for_export(true)
          columns = export_output[0].keys.map{|x| x.to_s.humanize}

          output = {
              'Name' => export[:name],
          }

          binding.pry

          columns_hash = {}
          columns.each_with_index.map do |x, i|
            test = {i => x}
            columns_hash.merge( {i => x})
          end


          output
        end

        # The DataExport class creates the header row for us so we need to ensure
        # we sort by longest hash length to ensure all headers appear
        data_for_export.sort_by(&:length).reverse
    end

    def column_names(export)
      class_name = export[:class]
      if class_name == SupportInterface::UnexplainedBreaksInWorkHistoryExport
        class_name::COLUMN_NAMES
      end
    end

    def provider_flow; end

    def candidate_flow; end

    def when_emails_are_sent; end

    def mailer_previews
      @previews = ActionMailer::Preview.all
      @page_title = 'Mailer Previews'
    end
  end
end
