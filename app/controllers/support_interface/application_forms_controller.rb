module SupportInterface
  class ApplicationFormsController < SupportInterfaceController
    def index
      application_forms = ApplicationForm.includes(:application_choices).sort_by(&:updated_at).reverse

      @application_forms = application_forms.map do |application_choice|
        ApplicationFormPresenter.new(application_choice)
      end
    end

    def show
      application_form = ApplicationForm
        .includes(:application_choices)
        .find(params[:application_form_id])

      @application_form = ApplicationFormPresenter.new(application_form)
    end

    def audit
      application_form = ApplicationForm
        .includes(:application_choices)
        .find(params[:application_form_id])

      @application_form = ApplicationFormAuditPresenter.new(application_form)
    end
  end
end
