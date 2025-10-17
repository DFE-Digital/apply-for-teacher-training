module ProviderInterface
  class CompletedOfferSummaryComponent < OfferSummaryComponent
    include ViewHelper
    include QualificationValueHelper

    def rows
      rows = [
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
        {
          key: location_key,
          value: course_option.site.name_and_address("\n"),
          action: {
            href: change_location_path,
            visually_hidden_text: 'location',
          },
        },
        {
          key: 'Qualification',
          value: qualification_text(course_option),
        },
        {
          key: 'Funding type',
          value: course.funding_type.humanize,
        },
      ]
      return rows if course_option.course.accredited_provider.blank?

      rows.insert(4, accredited_body_details(course_option))
    end

    def change_provider_path
      if @application_choice.pending_conditions?
        available_providers.length > 1 ? edit_provider_interface_application_choice_course_providers_path(application_choice) : nil
      else
        available_providers.length > 1 ? edit_provider_interface_application_choice_offer_providers_path(application_choice) : nil
      end
    end

    def change_course_path
      if @application_choice.pending_conditions?
        available_courses.length > 1 ? edit_provider_interface_application_choice_course_courses_path(application_choice) : nil
      else
        available_courses.length > 1 ? edit_provider_interface_application_choice_offer_courses_path(application_choice) : nil
      end
    end

    def change_study_mode_path
      if @application_choice.pending_conditions?
        course.full_time_or_part_time? ? edit_provider_interface_application_choice_course_study_modes_path(application_choice) : nil
      else
        course.full_time_or_part_time? ? edit_provider_interface_application_choice_offer_study_modes_path(application_choice) : nil
      end
    end

    def change_location_path
      if @application_choice.pending_conditions?
        available_course_options.length > 1 ? edit_provider_interface_application_choice_course_locations_path(application_choice) : nil
      else
        available_course_options.length > 1 ? edit_provider_interface_application_choice_offer_locations_path(application_choice) : nil
      end
    end

    def mode
      :edit
    end
  end
end
