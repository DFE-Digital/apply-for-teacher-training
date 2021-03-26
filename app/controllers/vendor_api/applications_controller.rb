module VendorAPI
  class ApplicationsController < VendorAPIController
    def index
      application_choices = get_application_choices_for_provider_since(
        since: since_param,
      )

      render json: { data: MultipleApplicationsPresenter.new(application_choices).as_json }
    end

    def show
      application_choice = application_choices_visible_to_provider.find(params[:application_id])

      render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
    end

  private

    def application_choices_visible_to_provider
      GetApplicationChoicesForProviders
        .call(
          providers: current_provider,
          vendor_api: true,
          includes: [
            application_form: %i[candidate application_qualifications application_work_experiences application_work_history_breaks application_volunteering_experiences english_proficiency],
            course_option: [{ course: %i[provider] }, :site],
            offered_course_option: [{ course: %i[provider] }, :site],
          ],
        )
    end

    def get_application_choices_for_provider_since(since:)
      application_choices_visible_to_provider
        .where('application_choices.updated_at > ?', since)
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
