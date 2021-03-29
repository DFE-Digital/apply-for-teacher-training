module RegisterAPI
  class ApplicationsController < ActionController::API
    include ServiceAPIUserAuthentication

    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ParameterInvalid, with: :parameter_invalid

    def index
      application_choices = GetRecruitedApplicationChoices.call(
        recruitment_cycle_year: recruitment_cycle_year_param,
        changed_since: changed_since,
      )

      render json: { data: MultipleApplicationsPresenter.new(application_choices, api: RegisterAPI).as_json }
    end

    def parameter_missing(e)
      render json: { errors: [{ error: 'ParameterMissing', message: e }] }, status: :unprocessable_entity
    end

    def parameter_invalid(e)
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
    end

  private

    def recruitment_cycle_year_param
      year = params.fetch(:recruitment_cycle_year)
      raise ParameterInvalid, 'Parameter is invalid: recruitment_cycle_year' unless year.in?(RecruitmentCycle.years_visible_to_providers.map(&:to_s))

      year
    end

    def changed_since
      changed_since_value = params[:changed_since]

      return if changed_since_value.blank?

      begin
        since = Time.zone.iso8601(changed_since_value)
        raise ParameterInvalid, 'Parameter is invalid (date is nonsense): changed_since' unless since.year.positive?

        since
      rescue ArgumentError, KeyError
        raise ParameterInvalid, 'Parameter is invalid (should be ISO8601): changed_since'
      end
    end
  end
end
