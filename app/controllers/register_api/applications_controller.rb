module RegisterAPI
  class ApplicationsController < ActionController::API
    include ServiceAPIUserAuthentication

    def index
      application_choices = get_recruited_applications(
        recruitment_cycle_year: recruitment_cycle_year_param,
      )
      render json: { data: MultipleApplicationsPresenter.new(application_choices, api: RegisterAPI).as_json }
    end

  private

    def get_recruited_applications(recruitment_cycle_year:)
      ApplicationChoice.includes([:application_form])
        .where(application_forms: { recruitment_cycle_year: recruitment_cycle_year }).references(:application_forms)
        .where(status: ApplicationStateChange::STATES_VISIBLE_TO_REGISTER)
        .where.not(recruited_at: nil)
    end

    def recruitment_cycle_year_param
      year = params.fetch(:recruitment_cycle_year)
      raise ParameterInvalid, 'Parameter is invalid: recruitment_cycle_year' unless year.in?(RecruitmentCycle.years_visible_to_providers.map(&:to_s))

      year
    rescue ArgumentError
      raise ParameterInvalid, 'Parameter is invalid: recruitment_cycle_year'
    end
  end
end
