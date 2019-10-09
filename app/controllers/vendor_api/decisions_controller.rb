module VendorApi
  class InvalidMetadata < StandardError; end

  class DecisionsController < VendorApiController
    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found
    rescue_from InvalidMetadata, with: :invalid_metadata

    def make_offer
      decision = MakeAnOffer.new(
        application_choice: application_choice,
        offer_conditions: params[:data],
      )

      repond_to_decision(decision)
    end

    def confirm_conditions_met
      decision = ConfirmOfferConditions.new(
        application_choice: application_choice,
      )

      repond_to_decision(decision)
    end

    def reject
      decision = RejectApplication.new(
        application_choice: application_choice,
        rejection: params[:data],
      )

      repond_to_decision(decision)
    end

    def confirm_enrolment
      raise InvalidMetadata unless Metadata.new(params[:meta]).valid?

      decision = ConfirmEnrolment.new(
        application_choice: application_choice,
      )

      repond_to_decision(decision)
    end

  private

    def application_choice
      @application_choice ||= ApplicationChoice.find(params[:application_id])
    end

    def invalid_metadata(_e)
      render json: {
        errors: [{
                   error: 'MetadataMissing',
                   message: 'A valid meta key, containing timestamp and attribution, was not included on the request body',
                 }],
      }, status: 422
    end

    def repond_to_decision(decision)
      if decision.save
        render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
      else
        render_bad_request(decision.errors)
      end
    end

    # Takes a object with ActiveModel::Validations and render the `errors`
    # as API response.
    def render_bad_request(errors)
      error_responses = errors.map { |_key, message| { error: 'BadRequest', message: message } }
      render status: 422, json: { errors: error_responses }
    end
  end
end
