module VendorAPI
  module APIValidationsAndErrorHandling
    extend ActiveSupport::Concern

    included do
      before_action :validate_metadata!

      rescue_from ValidationException, with: :render_validation_error
      rescue_from Workflow::NoTransitionAllowed, with: :render_workflow_transition_error
      rescue_from ProviderAuthorisation::NotAuthorisedError, with: :render_unauthorised_error
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_error
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
            error: 'NotAuthorisedError',
            message: e.message,
          },
        ],
      }
    end

    def render_not_found_error(_)
      render status: :not_found, json: {
        errors: [
          {
            error: 'NotFound',
            message: 'Unable to find Application(s)',
          },
        ],
      }
    end

    def render_validation_errors(errors)
      error_responses = errors.full_messages.map { |message| { error: 'ValidationError', message: message } }
      render status: :unprocessable_entity, json: { errors: error_responses }
    end

    def render_validation_error(e)
      render status: :unprocessable_entity, json: e.as_json
    end
  end
end
