module SupportInterface
  class ApplicationFormsController < SupportInterfaceController
    def index
      @filter = SupportInterface::ApplicationsFilter.new(params: filter_params)
      @pagy, @application_forms = @filter.filter_records(ApplicationForm)
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

    def filter_params
      if params[:remove] && !params[:year]
        params
      else
        params.with_defaults(year: [RecruitmentCycleTimetable.current_year.to_s])
      end
    end
  end
end
