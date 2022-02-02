module VendorAPI
  class ApplicationsController < VendorAPIController
    include ApplicationDataConcerns

    def index
      render json: serialized_application_choices_data
    end

    def show
      render json: SingleApplicationPresenter.new(version_number, application_choice).serialized_json
    end

  private

    def serialized_application_choices_data
      MultipleApplicationsPresenter.new(version_number, get_application_choices_for_provider_since(since: since_param), pagination_params).serialized_applications_data
    end

    def get_application_choices_for_provider_since(since:)
      application_choices_visible_to_provider
        .where('application_choices.updated_at > ?', since)
        .order('application_choices.updated_at DESC')
    end

    def pagination_params
      {
        since: since_param.iso8601,
        page: params[:page],
        per_page: params[:per_page],
        api_version: params[:api_version],
        url: url_for(
          controller: params[:controller],
          action: params[:action],
          host: request.host,
          api_version: params[:api_version],
        ),
      }
    end

    def since_param
      since_value = params.fetch(:since)

      begin
        since = Time.zone.iso8601(since_value)
        raise ParameterInvalid, 'Parameter is invalid (date is nonsense): since' unless since.year.positive?

        since
      rescue ArgumentError, KeyError
        raise ParameterInvalid, 'Parameter is invalid (should be ISO8601): since'
      end
    end
  end
end
