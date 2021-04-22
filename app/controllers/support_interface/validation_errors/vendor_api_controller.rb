module SupportInterface
  module ValidationErrors
    class VendorAPIController < SupportInterface::ValidationErrorsController
      def index
        @grouped_counts = VendorAPIRequest.validation_errors.group(:request_path).order('count_all DESC').count
        @grouped_column_error_counts = VendorAPIRequest.list_of_distinct_errors_with_count
      end

      def search
        @vendor_api_requests = VendorAPIRequest
          .search_validation_errors(params)
          .includes('provider')
          .order('created_at DESC')
          .page(params[:page] || 1)
      end

      def summary
        sort_param = params.permit(:sortby)[:sortby]

        @validation_error_summary = ::VendorAPIRequestSummaryQuery.new(sort_param).call
      end
    end
  end
end
