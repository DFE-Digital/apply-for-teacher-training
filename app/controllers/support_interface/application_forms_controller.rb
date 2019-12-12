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

    def hide_in_reporting
      application_form = ApplicationForm.find(params[:application_form_id])
      application_form.candidate.update!(hide_in_reporting: true)
      flash[:success] = 'Candidate will now be hidden in reporting'
      redirect_to support_interface_application_form_path(application_form)
    end

    def show_in_reporting
      application_form = ApplicationForm.find(params[:application_form_id])
      application_form.candidate.update!(hide_in_reporting: false)
      flash[:success] = 'Candidate will now be shown in reporting'
      redirect_to support_interface_application_form_path(application_form)
    end
  end
end
