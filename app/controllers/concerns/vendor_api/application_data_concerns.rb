module VendorAPI
  module ApplicationDataConcerns
  private

    def application_choice_id
      params.permit(:application_id)[:application_id]
    end

    def application_choice
      @application_choice ||= application_choices_visible_to_provider.find(application_choice_id)
    end

    def render_application
      render json: application_json
    end

    def application_json
      %({"data":#{ApplicationPresenter.new(version_number, application_choice).serialized_json}})
    end

    def application_choices_visible_to_provider(includes = include_properties)
      options = { providers: [current_provider],
                  exclude_deferrals: exclude_deferrals }
      options.merge!(includes: includes) if includes.present?

      GetApplicationChoicesForProviders.call(options)
    end

    def exclude_deferrals
      full_api_version_number.eql?(VendorAPI::VERSION_1_0)
    end

    def include_properties
      [
        :notes,
        offer: %i[conditions],
        application_form: %i[candidate application_qualifications application_references application_work_experiences application_work_history_breaks application_volunteering_experiences english_proficiency],
        course_option: [{ course: %i[provider] }, :site],
        current_course_option: [{ course: %i[provider] }, :site],
        interviews: %i[provider],
      ]
    end
  end
end
