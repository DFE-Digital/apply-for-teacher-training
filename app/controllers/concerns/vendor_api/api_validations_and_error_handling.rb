module VendorAPI
  module APIValidationsAndErrorHandling
    extend ActiveSupport::Concern

    NOT_FOUND_MODEL_MAPPINGS = {
      'ApplicationChoice' => 'Application',
    }.freeze

    included do
      before_action :require_valid_api_token!
      before_action :validate_metadata!

      rescue_from ValidationException, with: :render_validation_error
      rescue_from Workflow::NoTransitionAllowed, with: :render_workflow_transition_error
      rescue_from ProviderAuthorisation::NotAuthorisedError, with: :render_unauthorised_error
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_error
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from ParameterInvalid, with: :parameter_invalid

      # Makes PG::QueryCanceled statement timeout errors appear in Skylight
      # against the controller action that triggered them
      # instead of bundling them with every other ErrorsController#internal_server_error
      rescue_from ActiveRecord::QueryCanceled, with: :statement_timeout
    end

    def require_valid_api_token!
      return @current_vendor_api_token.update!(last_used_at: Time.zone.now) if valid_api_token?

      raise ProviderAuthorisation::NotAuthorisedError, 'Please provide a valid authentication token'
    end

    def valid_api_token?
      authenticate_with_http_token do |unhashed_token|
        @current_vendor_api_token = VendorAPIToken.find_by_unhashed_token(unhashed_token)
      end
    end

    def validate_metadata!
      @metadata = Metadata.new(params[:meta])

      if @metadata.invalid?
        render_validation_errors(@metadata.errors)
      end
    end

    def render_workflow_transition_error(_)
      render status: :unprocessable_entity, json: {
        errors: [
          error: 'StateTransitionError',
          message: I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
        ],
      }
    end

    def render_unauthorised_error(e)
      render status: :unauthorized, json: {
        errors: [
          {
            error: 'Unauthorized',
            message: e.message,
          },
        ],
      }
    end

    def render_not_found_error(e)
      model_name = NOT_FOUND_MODEL_MAPPINGS[e.model] || e.model

      render status: :not_found, json: {
        errors: [
          {
            error: 'NotFound',
            message: "Unable to find #{model_name}s",
          },
        ],
      }
    end

    def render_validation_errors(errors)
      error_responses = errors.full_messages.map { |message| { error: 'UnprocessableEntity', message: } }

      render status: :unprocessable_entity, json: {
        errors: error_responses,
      }
    end

    def parameter_missing(e)
      error_message = e.message.split("\n").first

      render status: :unprocessable_entity, json: {
        errors: [
          {
            error: 'ParameterMissing',
            message: error_message,
          },
        ],
      }
    end

    def parameter_invalid(e)
      render status: :unprocessable_entity, json: {
        errors: [
          {
            error: 'ParameterInvalid',
            message: e,
          },
        ],
      }
    end

    def statement_timeout
      render status: :internal_server_error, json: {
        errors: [
          {
            error: 'InternalServerError',
            message: 'The server encountered an unexpected condition that prevented it from fulfilling the request',
          },
        ],
      }
    end

    def render_validation_error(e)
      render status: :unprocessable_entity, json: e.as_json
    end
  end
end
