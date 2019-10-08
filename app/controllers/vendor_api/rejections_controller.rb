module VendorApi
  class RejectionsController < VendorApiController
    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found

    def create
      application_choice = ApplicationChoice.find(params[:application_id])

      result = RejectApplication.new(application_choice: application_choice, rejection: params[:data]).call

      if result.successful?
        render json: {
          data: SingleApplicationPresenter.new(result.application_choice).as_json,
        }
      end
    end
  end
end
