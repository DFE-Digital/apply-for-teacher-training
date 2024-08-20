module SupportInterface
  module ValidationErrors
    class VendorAPIController < SupportInterface::ValidationErrorsController
      PAGY_PER_PAGE = 30

      def index
        @grouped_counts = VendorAPIRequest.unprocessable_entities.group(:request_path).order('count_all DESC').count
        @list_of_distinct_errors_with_counts = VendorAPIRequest.list_of_distinct_errors_with_count
      end

      def search
        @vendor_api_requests = VendorAPIRequest
          .search_validation_errors(params)
          .includes('provider')
          .order('created_at DESC')

        @pagy, @vendor_api_requests = pagy(@vendor_api_requests, limit: PAGY_PER_PAGE)
      end

      def summary
        sort_param = params.permit(:sortby)[:sortby]

        @validation_error_summary = ::VendorAPIRequestSummaryQuery.new(sort_param).call
      end
    end
  end
end
