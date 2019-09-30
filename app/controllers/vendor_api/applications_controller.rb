module VendorApi
  class ApplicationsController < VendorApiController
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found

    def index
      application_choices = ApplicationChoice.where(
        provider_ucas_code: params.fetch(:provider),
      )
      .joins(:application_form)
      .where(
        'application_forms.updated_at > ?', params.fetch(:since).to_datetime
      )

      render json: { data: MultipleApplicationsPresenter.new(application_choices).as_json }
    end

    def show
      application_choice = ApplicationChoice.find(params[:application_id])

      render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
    end

  private

    def parameter_missing(e)
      render json: { errors: [{ error: 'ParameterMissing', message: e }] }, status: 422
    end

    def application_not_found(_e)
      render json: { errors: [{ error: 'NotFound', message: "Could not find an application with ID #{params[:application_id]}" }] }, status: 404
    end
  end
end
