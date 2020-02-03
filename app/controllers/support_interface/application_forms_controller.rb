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

    def send_to_provider
      application_form = ApplicationForm.find(params[:application_form_id])
      SendApplicationToProviderWithoutReferences.new(application_form).call
      flash[:success] = 'The application has been send to provider without references'
      redirect_to support_interface_applications_path(application_form)
    end
  end
end
