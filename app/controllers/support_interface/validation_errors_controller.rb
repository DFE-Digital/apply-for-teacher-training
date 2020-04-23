module SupportInterface
  class ValidationErrorsController < SupportInterfaceController
    def index
      @grouped_counts = ValidationError.group(:form_object).order('count_all DESC').count
    end

    def show
      @validation_errors = ValidationError.where(form_object: params[:form_object]).order('created_at DESC')
    end
  end
end
