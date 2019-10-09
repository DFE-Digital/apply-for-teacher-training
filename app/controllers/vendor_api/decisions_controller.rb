module VendorApi
  class InvalidMetadata < StandardError; end

  class DecisionsController < VendorApiController
    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found
    rescue_from InvalidMetadata, with: :invalid_metadata

    def make_offer
      application_choice = ApplicationChoice.find(params[:application_id])

      make_an_offer = MakeAnOffer.new(application_choice: application_choice, offer_conditions: params.fetch(:data, {})[:conditions]).call
      if make_an_offer.successful?
        render json: { data: SingleApplicationPresenter.new(make_an_offer.application_choice).as_json }
      end
    end

    def confirm_conditions_met
      application_choice = ApplicationChoice.find(params[:application_id])

      confirm = ConfirmOfferConditions.new(application_choice: application_choice).call

      if confirm.successful?
        render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
      end
    end

    def reject
      application_choice = ApplicationChoice.find(params[:application_id])

      result = RejectApplication.new(application_choice: application_choice, rejection: params[:data]).call

      if result.successful?
        render json: {
          data: SingleApplicationPresenter.new(result.application_choice).as_json,
        }
      end
    end

    def confirm_enrolment
      raise InvalidMetadata unless Metadata.new(params[:meta]).valid?

      application_choice = ApplicationChoice.find(params[:application_id])
      result = ConfirmEnrolment.new(application_choice: application_choice).call

      if result.successful?
        render json: {
          data: SingleApplicationPresenter.new(result.application_choice).as_json,
        }
      end
    end

  private

    def invalid_metadata(_e)
      render json: {
        errors: [{
                   error: 'MetadataMissing',
                   message: 'A valid meta key, containing timestamp and attribution, was not included on the request body',
                 }],
      }, status: 422
    end
  end
end
