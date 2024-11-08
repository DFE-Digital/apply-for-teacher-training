module RegisterAPI
  class ApplicationsController < ApplicationAPIController
    include ServiceAPIUserAuthentication
    include RemoveBrowserOnlyHeaders
    include Pagy::Backend

    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ParameterInvalid, with: :parameter_invalid

    # Makes PG::QueryCanceled statement timeout errors appear in Skylight
    # against the controller action that triggered them
    # instead of bundling them with every other ErrorsController#internal_server_error
    rescue_from ActiveRecord::QueryCanceled, with: :statement_timeout

    rescue_from Pagy::OverflowError, with: :page_parameter_invalid
    rescue_from PerPageParameterInvalid, with: :per_page_parameter_invalid

    DEFAULT_PER_PAGE = 50
    MAX_PER_PAGE = 50

    def index
      render json: { data: serialized_application_choices }
    end

    def parameter_missing(e)
      error_message = e.message.split("\n").first
      render json: { errors: [{ error: 'ParameterMissing', message: error_message }] }, status: :unprocessable_entity
    end

    def parameter_invalid(e)
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
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

    def page_parameter_invalid(e)
      last_page = e.message.scan(/\d+/)[1]
      error_message = "expected 'page' parameter to be between 1 and #{last_page}, got #{params[:page]}"
      render json: {
        errors: [
          {
            error: 'PageParameterInvalid',
            message: error_message,
          },
        ],
      }, status: :unprocessable_entity
    end

    def per_page_parameter_invalid
      render json: {
        errors: [
          {
            error: 'PerPageParameterInvalid',
            message: "the 'per_page' parameter cannot exceed #{MAX_PER_PAGE} results per page",
          },
        ],
      }, status: :unprocessable_entity
    end

  private

    def paginate(scope)
      pagy, paginated_records = pagy(scope, limit: per_page, page:, overflow: :exception)
      pagy_headers_merge(pagy)

      paginated_records
    end

    def per_page
      raise PerPageParameterInvalid unless params[:per_page].to_i <= MAX_PER_PAGE

      [(params[:per_page] || DEFAULT_PER_PAGE).to_i, MAX_PER_PAGE].min
    end

    def page
      (params[:page] || 1).to_i
    end

    def serialized_application_choices
      paginate(recruited_application_choices).map do |application_choice|
        SingleApplicationPresenter.new(application_choice).as_json
      end
    end

    def recruited_application_choices
      RegisterAPIApplicationChoices.call(
        recruitment_cycle_year: recruitment_cycle_year_param,
        changed_since:,
      )
    end

    def recruitment_cycle_year_param
      year = params.fetch(:recruitment_cycle_year)
      raise ParameterInvalid, 'Parameter is invalid: recruitment_cycle_year' unless year.in?(RecruitmentCycle.years_available_to_register.map(&:to_s))

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
