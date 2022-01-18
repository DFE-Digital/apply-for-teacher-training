module VendorAPI
  module ApplicationChoiceConcerns
  private

    def application_choice_id
      params.permit(:application_id)[:application_id]
    end

    def application_choice
      @application_choice ||= application_choices_visible_to_provider.find(application_choice_id)
    end

    def application_choices_visible_to_provider
      GetApplicationChoicesForProviders.call(providers: [current_provider],
                                             exclude_deferrals: exclude_deferrals)
    end

    def render_application
      render json: { data: ApplicationPresenter.new(version_number, application_choice).as_json }.merge!(meta).to_json
    end

    def exclude_deferrals
      version_number.eql?('1.0')
    end

    def meta
      {
        meta:
        {
          api_version: version_number,
          timestamp: Time.zone.now.iso8601,
        },
      }
    end
  end
end
