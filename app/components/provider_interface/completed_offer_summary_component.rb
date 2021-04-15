module ProviderInterface
  class CompletedOfferSummaryComponent < OfferSummaryComponent
    include ViewHelper

    def rows
      rows = [
        { key: 'Training provider',
          value: course_option.provider.name_and_code,
          action: 'Change',
          change_path: change_provider_path },
        { key: 'Course',
          value: course_option.course.name_and_code,
          action: 'Change',
          change_path: change_course_path },
        { key: 'Full time or part time',
          value: course_option.study_mode.humanize,
          action: 'Change',
          change_path: change_study_mode_path },
        { key: 'Location',
          value: course_option.site.name_and_address,
          action: 'Change',
          change_path: change_location_path },
      ]
      return rows if course_option.course.accredited_provider.blank?

      rows << accredited_body_details(course_option)
    end

    def change_provider_path
      available_providers.length > 1 ? edit_provider_interface_application_choice_offer_providers_path(application_choice) : nil
    end

    def change_course_path
      available_courses.length > 1 ? edit_provider_interface_application_choice_offer_courses_path(application_choice) : nil
    end

    def change_study_mode_path
      course.full_time_or_part_time? ? edit_provider_interface_application_choice_offer_study_modes_path(application_choice) : nil
    end

    def change_location_path
      available_course_options.length > 1 ? edit_provider_interface_application_choice_offer_locations_path(application_choice) : nil
    end

    def mode
      :edit
    end
  end
end
