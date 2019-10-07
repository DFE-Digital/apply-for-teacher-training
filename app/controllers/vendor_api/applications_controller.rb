module VendorApi
  class ApplicationsController < VendorApiController
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ActiveRecord::RecordNotFound, with: :application_not_found

    def index
      application_choices = get_application_choices_for_provider_since(
        provider: params.fetch(:provider),
        since: params.fetch(:since),
      )

      render json: { data: MultipleApplicationsPresenter.new(application_choices).as_json }
    end

    def show
      application_choice = ApplicationChoice.find(params[:application_id])

      render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
    end

  private

    def get_application_choices_for_provider_since(provider:, since:)
      ApplicationChoice
        .where(provider_ucas_code: provider)
        .joins(:application_form)
        .where('application_forms.updated_at > ?', since.to_datetime)
    end

    def parameter_missing(e)
      render json: { errors: [{ error: 'ParameterMissing', message: e }] }, status: 422
    end
  end
end
