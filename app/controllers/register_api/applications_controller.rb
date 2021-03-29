module RegisterAPI
  class ApplicationsController < ActionController::API
    include ServiceAPIUserAuthentication

    def index
      application_choices = GetRecruitedApplicationChoices.call(
        recruitment_cycle_year: recruitment_cycle_year_param,
      )

      render json: { data: MultipleApplicationsPresenter.new(application_choices, api: RegisterAPI).as_json }
    end

  private

    def recruitment_cycle_year_param
      year = params.fetch(:recruitment_cycle_year)
      raise ParameterInvalid, 'Parameter is invalid: recruitment_cycle_year' unless year.in?(RecruitmentCycle.years_visible_to_providers.map(&:to_s))

      year
    end
  end
end
