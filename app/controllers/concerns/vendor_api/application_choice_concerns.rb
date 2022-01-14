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
                                             vendor_api: true)
    end

    def render_application
      render json: %({"data":#{ApplicationPresenter.new(version_number, application_choice).serialized_json}})
    end
  end
end
