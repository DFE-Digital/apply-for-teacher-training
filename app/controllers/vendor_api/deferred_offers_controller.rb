module VendorAPI
  class DeferredOffersController < VendorAPIController
    include ApplicationChoiceConcerns

    before_action :validate_metadata!
    rescue_from ValidationException, with: :render_validation_error

    def create
      DeferOffer.new(actor: audit_user, application_choice: application_choice).save!

      render_application
    rescue Workflow::NoTransitionAllowed
      render status: :unprocessable_entity, json: {
        errors: [
          error: 'StateTransitionError',
          message: I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
        ],
      }
    rescue ProviderAuthorisation::NotAuthorisedError => e
      render status: :unauthorised, json: {
        errors: [
          {
            error: 'NotAuthorisedError',
            message: e.message,
          },
        ],
      }
    rescue ActiveRecord::RecordNotFound => e
      render status: :not_found, json: {
        errors: [
          {
            error: 'NotFound',
            message: 'Unable to find Application(s)',
          },
        ],
      }
    end

  private

    def render_validation_errors(errors)
      error_responses = errors.full_messages.map { |message| { error: 'ValidationError', message: message } }
      render status: :unprocessable_entity, json: { errors: error_responses }
    end
  end
end
