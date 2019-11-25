module SupportInterface
  class ImportReferencesController < SupportInterfaceController
    def index; end

    def import
      csv_file = params[:csv_file]
      if csv_file && csv_file.content_type == 'text/csv'
        @output = ImportReferencesFromCsv.call(csv_file: csv_file)
        @successes, @errors = @output.partition { |o| o[:updated] }
      else
        @error = 'You must upload a CSV file'
        render :index
      end
    end
  end
end
