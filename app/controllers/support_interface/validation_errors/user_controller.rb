module SupportInterface
  module ValidationErrors
    class UserController < SupportInterfaceController
      PAGY_PER_PAGE = 30

      def index
        @grouped_counts = validation_error_scope.group(:form_object).order(count_all: :desc).count
        @list_of_distinct_errors_with_counts = validation_error_scope.list_of_distinct_errors_with_count
      end

      def search
        @validation_errors, @validation_errors_records = pagy(validation_error_scope.search(params).order(created_at: :desc), limit: PAGY_PER_PAGE)
      end

      def summary
        sort_param = params.permit(:sortby)[:sortby]

        @validation_error_summary = ::ValidationErrorSummaryQuery.new(service_scope, sort_param).call
      end

    private

      def validation_error_scope
        ValidationError.send(service_scope)
      end
    end
  end
end
