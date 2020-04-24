module SupportInterface
  class ValidationErrorsController < SupportInterfaceController
    def index
      @grouped_counts = ValidationError.group(:form_object).order('count_all DESC').count
    end

    def show
      @form_object = params[:form_object]
      @validation_errors = ValidationError.where(form_object: @form_object).order('created_at DESC')
    end
  end
end
