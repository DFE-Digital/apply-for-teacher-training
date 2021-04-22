module SupportInterface
  module ValidationErrors
    class VendorAPIController < SupportInterface::ValidationErrorsController
      def index
        @grouped_counts = VendorAPIRequest.validation_errors.group(:request_path).order('count_all DESC').count
        @grouped_column_error_counts = VendorAPIRequest.list_of_distinct_errors_with_count
      end
    end
  end
end
