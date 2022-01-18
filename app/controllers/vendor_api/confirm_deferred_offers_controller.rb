module VendorAPI
  class ConfirmDeferredOffersController < VendorAPIController
    include ApplicationChoiceConcerns

    before_action :validate_metadata!
    rescue_from ValidationException, with: :render_validation_error

    def create
      ReinstateDeferredOffer.new(actor: audit_user,
                                 application_choice: application_choice,
                                 conditions_met: true).call

      render_application
    end

    def application_choices_visible_to_provider
      GetApplicationChoicesForProviders.call(providers: [current_provider],
                                             exclude_deferrals: exclude_deferrals,
                                             recruitment_cycle_year: recruitment_cycle_years_available)
    end

    def recruitment_cycle_years_available
      RecruitmentCycle.years_visible_to_providers - [RecruitmentCycle.current_year]
    end

  private

    def render_validation_errors(errors)
      error_responses = errors.full_messages.map { |message| { error: 'ValidationError', message: message } }
      render status: :unprocessable_entity, json: { errors: error_responses }
    end

    def render_validation_error(e)
      render status: :unprocessable_entity, json: e.as_json
    end
  end
end
