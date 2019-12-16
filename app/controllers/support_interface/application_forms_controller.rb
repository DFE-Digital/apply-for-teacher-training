module SupportInterface
  class ApplicationFormsController < SupportInterfaceController
    def index
      @application_forms = ApplicationForm.includes(:candidate, :application_choices).sort_by(&:updated_at).reverse
    end

    def show
      @application_form = ApplicationForm
        .find(params[:application_form_id])
    end

    def audit
      @application_form = ApplicationForm
        .find(params[:application_form_id])
    end
  end
end
