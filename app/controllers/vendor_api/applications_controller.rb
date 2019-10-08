module VendorApi
  class ApplicationsController < VendorApiController
    def index
      application_choices = get_application_choices_for_provider_since(
        provider: params.fetch(:provider_ucas_code),
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
  end
end
