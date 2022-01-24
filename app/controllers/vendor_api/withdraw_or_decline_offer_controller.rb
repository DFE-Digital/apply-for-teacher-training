module VendorAPI
  class WithdrawOrDeclineOfferController < VendorAPIController
    before_action :validate_metadata!

    include ApplicationDataConcerns

    def create
      application = DeclineOrWithdrawApplication.new(
        actor: audit_user,
        application_choice: application_choice,
      )

      if application.save!
        render_application
      else
        invalid_transition
      end
    rescue ProviderAuthorisation::NotAuthorisedError => e
      render status: :unprocessable_entity, json: {
        errors: [
          {
            error: 'NotAuthorisedError',
            message: e.message,
          },
        ],
      }
    end

  private

    def invalid_transition
      render status: :unprocessable_entity, json: {
        errors: [
          error: 'StateTransitionError',
          message: I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
        ],
      }
    end

    def application_choice
      @application_choice ||= application_choices_visible_to_provider.find(params[:application_id])
    end

    def render_validation_errors(errors)
      error_responses = errors.full_messages.map { |message| { error: 'ValidationError', message: message } }
      render status: :unprocessable_entity, json: { errors: error_responses }
    end
  end
end
