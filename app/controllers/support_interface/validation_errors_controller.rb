module SupportInterface
  class ValidationErrorsController < SupportInterfaceController
    def index
      @grouped_counts = ValidationError.group(:form_object).order('count_all DESC').count
      @grouped_column_error_counts = ValidationError.list_of_distinct_errors_with_count
    end

    def search
      @validation_errors = ValidationErrorSearch
        .search(params)
        .includes('user')
        .order('created_at DESC')
        .page(params[:page] || 1)
    end

    def summary
      @validation_error_summary = ValidationErrorSummary.new.call
    end

    class ValidationErrorSummary
      COUNT_QUERY =
        'SELECT COUNT(*) AS incidents, COUNT(DISTINCT user_id) AS distinct_users
        FROM validation_errors
        WHERE created_at > $1'.freeze

      def call
        {
          last_week: errors_since(1.week.ago),
          last_month: errors_since(1.month.ago),
          all_time: errors_since(Time.zone.local(2000, 1, 1)),
        }
      end

    private

      def errors_since(start_date)
        ActiveRecord::Base.connection.exec_query(
          COUNT_QUERY,
          'SQL',
          [[nil, start_date]],
        ).first.with_indifferent_access
      end
    end

    class ValidationErrorSearch
      def self.search(params)
        scope = ValidationError
        scope = scope.where(form_object: params[:form_object]) if params[:form_object]
        scope = scope.where(user_id: params[:user_id]) if params[:user_id]
        scope = scope.where(id: params[:id]) if params[:id]
        scope = scope.where('details->? IS NOT NULL', params[:attribute]) if params[:attribute]
        scope
      end
    end
  end
end
