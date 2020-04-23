module SupportInterface
  class ValidationErrorsController < SupportInterfaceController
    def index
      @grouped_counts = ValidationError.group(:form_object).order('count_all DESC').count
    end
  end
end
