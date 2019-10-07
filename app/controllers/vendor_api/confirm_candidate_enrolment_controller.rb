module VendorApi
  class InvalidMetadata < StandardError; end

  class ConfirmCandidateEnrolmentController < VendorApiController
    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found
    rescue_from InvalidMetadata, with: :invalid_metadata

    def confirm
      check_metadata!

      application_choice = ApplicationChoice.find(params[:application_id])
      result = ConfirmEnrolment.new(application_choice: application_choice).call

      if result.successful?
        render json: {
          data: SingleApplicationPresenter.new(result.application_choice).as_json,
        }
      end
    end

  private

    def check_metadata!
      meta = params[:meta]

      unless meta.present? &&
          meta.keys.include?('attribution') &&
          meta.keys.include?('timestamp')

        raise InvalidMetadata
      end
    end

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
