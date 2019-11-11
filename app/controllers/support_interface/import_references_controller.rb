module SupportInterface
  class ImportReferencesController < SupportInterfaceController
    def index
    end

    def import
      csv_file = params[:csv_file]
      if csv_file && csv_file.content_type == "text/csv"
        @output = ImportReferencesFromCsv.call(csv_file: csv_file)

        @output.each do |result|
          if result[:application_form]
            result[:application_form] = ApplicationFormPresenter.new(result[:application_form])
          end
        end

        @successes, @errors = @output.partition { |o| o[:updated] }
      end
    end
  end
end
