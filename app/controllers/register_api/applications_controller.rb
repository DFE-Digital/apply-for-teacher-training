module RegisterAPI
  class ApplicationsController < ApplicationAPIController
    include ServiceAPIUserAuthentication

    rescue_from ParameterInvalid, with: :parameter_invalid

    # Makes PG::QueryCanceled statement timeout errors appear in Skylight
    # against the controller action that triggered them
    # instead of bundling them with every other ErrorsController#internal_server_error
    rescue_from ActiveRecord::QueryCanceled, with: :statement_timeout

    def index
      render json: { data: serialized_application_choices }
    end

    def statement_timeout
      render json: {
        errors: [
          {
            error: 'InternalServerError',
            message: 'The server encountered an unexpected condition that prevented it from fulfilling the request',
          },
        ],
      }, status: :internal_server_error
    end

  private

    def serialized_application_choices
      recruited_application_choices.find_each(batch_size: 100).map do |application_choice|
        SingleApplicationPresenter.new(application_choice).as_json
      end
    end

    def recruited_application_choices
      GetRecruitedApplicationChoices.call(
        recruitment_cycle_year: recruitment_cycle_year_param,
        changed_since: changed_since,
      )
    end

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
