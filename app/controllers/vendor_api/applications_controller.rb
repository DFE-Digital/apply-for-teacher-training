module VendorApi
  class ApplicationsController < VendorApiController
    def index
      application_choices = get_application_choices_for_provider_since(
        since: params.fetch(:since),
      )

      render json: { data: MultipleApplicationsPresenter.new(application_choices).as_json }
    end

    def show
      application_choice = ApplicationChoice
      .for_provider(current_provider.code)
      .visible_to_provider
      .find(params[:application_id])

      render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
    end

  private

    def get_application_choices_for_provider_since(since:)
      ApplicationChoice
        .for_provider(current_provider.code)
        .visible_to_provider
        .where('application_choices.updated_at > ?', since.to_datetime)
    end
  end
end
