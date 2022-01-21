module VendorAPI
  class ApplicationsController < VendorAPIController
    include ApplicationDataConcerns

    def index
      render json: serialized_application_choices_data
    end

    def show
      render_application
    end

  private

    def serialized_application_choices_data
      json_data = get_application_choices_for_provider_since(since: since_param).map do |application_choice|
        ApplicationPresenter.new(version_number, application_choice).serialized_json
      end

      %({"data":[#{json_data.join(',')}]})
    end

    def get_application_choices_for_provider_since(since:)
      application_choices_visible_to_provider(include_properties)
        .where('application_choices.updated_at > ?', since)
        .find_each(batch_size: 500)
        .sort_by(&:updated_at)
        .reverse
    end

    def include_properties
      [
        offer: %i[conditions],
        application_form: %i[candidate application_qualifications application_references application_work_experiences application_work_history_breaks application_volunteering_experiences english_proficiency],
        course_option: [{ course: %i[provider] }, :site],
        current_course_option: [{ course: %i[provider] }, :site],
      ]
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
