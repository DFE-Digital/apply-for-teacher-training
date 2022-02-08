module VendorAPI
  class ApplicationsController < VendorAPIController
    include ApplicationDataConcerns

    rescue_from Pagy::OverflowError, with: :page_parameter_invalid
    rescue_from PerPageParameterInvalid, with: :per_page_parameter_invalid

    def index
      render json: serialized_application_choices_data
    end

    def show
      render json: SingleApplicationPresenter.new(version_number, application_choice).serialized_json
    end

  private

    def serialized_application_choices_data
      MultipleApplicationsPresenter.new(version_number, get_application_choices_for_provider_since(since: since_param), request, pagination_params).serialized_applications_data
    end

    def get_application_choices_for_provider_since(since:)
      application_choices_visible_to_provider
        .where('application_choices.updated_at > ?', since)
    end

    def pagination_params
      {
        since: since_param.iso8601,
        page: params[:page],
        per_page: params[:per_page],
        url: request.original_url,
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

    def page_parameter_invalid(e)
      last_page = e.message.scan(/\d+/)[1]
      error_message = "expected 'page' parameter to be between 1 and #{last_page}, got #{params[:page]}"
      render json: { errors: [{ error: 'PageParameterInvalid', message: error_message }] }, status: :unprocessable_entity
    end

    def per_page_parameter_invalid
      render json: {
        errors: [
          {
            error: 'PerPageParameterInvalid',
            message: "the 'per_page' parameter cannot exceed #{PaginationAPIData::MAX_PER_PAGE} results per page",
          },
        ],
      }, status: :unprocessable_entity
    end
  end
end
