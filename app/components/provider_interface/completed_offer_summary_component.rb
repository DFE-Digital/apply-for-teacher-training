module ProviderInterface
  class CompletedOfferSummaryComponent < OfferSummaryComponent
    include ViewHelper
    include QualificationValueHelper

    def rows
      [
        {
          key: 'Training provider',
          value: course_option.provider.name_and_code,
          action: {
            href: change_provider_path,
            visually_hidden_text: 'training provider',
          },
        },
        {
          key: 'Course',
          value: course_option.course.name_and_code,
          action: {
            href: change_course_path,
            visually_hidden_text: 'course details',
          },
        },
        {
          key: 'Full time or part time',
          value: course_option.study_mode.humanize,
          action: {
            href: change_study_mode_path,
            visually_hidden_text: 'if full time or part time',
          },
        },
        location_row,
        accredited_body_details,
        {
          key: 'Qualification',
          value: qualification_text(course_option),
        },
        {
          key: 'Funding type',
          value: course.funding_type.humanize,
        },
      ].compact_blank
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
