module SupportInterface
  class ApplicationFormsController < SupportInterfaceController
    def index
      @application_forms = ApplicationForm.includes(:application_choices).sort_by(&:updated_at).reverse
    end

    def show
      @application_form = ApplicationForm
        .includes(:application_choices)
        .find(params[:application_form_id])
    end

    def audit
      @application_form = ApplicationForm
        .includes(:application_choices)
        .find(params[:application_form_id])
    end
  end
end
