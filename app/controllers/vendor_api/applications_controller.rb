module VendorAPI
  class ApplicationsController < VendorAPIController
    def index
      application_choices = get_application_choices_for_provider_since(
        since: since_param,
      )

      render json: { data: MultipleApplicationsPresenter.new(application_choices).as_json }
    end

    def show
      application_choice = GetApplicationChoicesForProviders.call(providers: current_provider, vendor_api: true)
        .find(params[:application_id])

      render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
    end

  private

    def get_application_choices_for_provider_since(since:)
      GetApplicationChoicesForProviders.call(providers: current_provider, vendor_api: true)
        .where('application_choices.updated_at > ?', since)
    end

    def since_param
      since = Time.zone.iso8601(params.fetch(:since))
      raise ParameterInvalid, 'Parameter is invalid (date is nonsense): since' unless since.year.positive?

      since
    rescue ArgumentError
      raise ParameterInvalid, 'Parameter is invalid (should be ISO8601): since'
    end
  end
end
