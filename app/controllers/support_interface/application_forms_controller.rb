module SupportInterface
  class ApplicationFormsController < SupportInterfaceController
    def index
      @filter = SupportInterface::ApplicationsFilter.new(params:)
      result = @filter.filter_records(ApplicationForm)
      @pagy = result[:pagy]
      @application_forms = result[:records]
    end

    def show
      @application_form = application_form
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
