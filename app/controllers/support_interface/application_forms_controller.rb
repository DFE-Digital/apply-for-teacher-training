module SupportInterface
  class ApplicationFormsController < SupportInterfaceController
    def index
      @application_forms = ApplicationForm
        .joins(:candidate)
        .includes(:candidate, :application_choices)
        .order(updated_at: :desc)
        .page(params[:page] || 1).per(15)

      if params[:q]
        @application_forms = @application_forms.where("CONCAT(application_forms.first_name, ' ', application_forms.last_name, ' ', candidates.email_address, ' ', application_forms.support_reference) ILIKE ?", "%#{params[:q]}%")
      end

      if params[:phase]
        @application_forms = @application_forms.where('phase IN (?)', params[:phase])
      end

      @filter = SupportInterface::ApplicationsFilter.new(params: params)
    end

    def show
      @application_form = application_form
    end

    def unavailable_choices
      @monitor = SupportInterface::ApplicationMonitor.new
    end

    def audit
      @application_form = application_form
    end

  private

    def application_form
      @_application_form ||= ApplicationForm.find(params[:application_form_id])
    end
  end
end
