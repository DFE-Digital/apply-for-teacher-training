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
