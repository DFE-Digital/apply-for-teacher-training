module VendorApi
  class ConfirmCandidateEnrolmentController < VendorApiController
    def confirm
      application_choice = ApplicationChoice.find(params[:application_id])

      result = ConfirmEnrolment.new(application_choice: application_choice).call

      if(result.successful?)
        render json: {
          data: SingleApplicationPresenter.new(result.application_choice).as_json,
        }
      end
    end
  end
end
