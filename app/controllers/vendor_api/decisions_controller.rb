module VendorApi
  class DecisionsController < VendorApiController
    before_action :validate_metadata!

    def make_offer
      api_user = VendorApiUser.find_or_initialize_by(
        vendor_api_token_id: @current_vendor_api_token.id,
      )

      decision = MakeAnOffer.new(
        actor: api_user,
        application_choice: application_choice,
        offer_conditions: params.dig(:data, :conditions),
        course_data: params.dig(:data, :course),
      )

      respond_to_decision(decision)
    end

    def confirm_conditions_met
      decision = ConfirmOfferConditions.new(
        application_choice: application_choice,
      )

      respond_to_decision(decision)
    end

    def conditions_not_met
      decision = ConditionsNotMet.new(
        application_choice: application_choice,
      )

      respond_to_decision(decision)
    end

    def reject
      decision =
        if application_choice.offer?
          WithdrawOffer.new(
            application_choice: application_choice,
            offer_withdrawal_reason: params.dig(:data, :reason),
          )
        else
          RejectApplication.new(
            application_choice: application_choice,
            rejection_reason: params.dig(:data, :reason),
          )
        end

      respond_to_decision(decision)
    end

    def confirm_enrolment
      decision = ConfirmEnrolment.new(
        application_choice: application_choice,
      )

      respond_to_decision(decision)
    end

  private

    def application_choice
      @application_choice ||= GetApplicationChoicesForProviders.call(providers: current_provider)
        .find(params[:application_id])
    end

    def respond_to_decision(decision)
      if decision.save
        render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
      else
        render_validation_errors(decision.errors)
      end
    end

    # Takes errors from ActiveModel::Validations and render them in the API response
    def render_validation_errors(errors)
      error_responses = errors.full_messages.map { |message| { error: 'ValidationError', message: message } }
      render status: :unprocessable_entity, json: { errors: error_responses }
    end
  end
end
