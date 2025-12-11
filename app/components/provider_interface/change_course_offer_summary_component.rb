module ProviderInterface
  class ChangeCourseOfferSummaryComponent < CompletedOfferSummaryComponent
    include ViewHelper

    def rows
      [
        { key: 'Training provider',
          value: course_option.provider.name_and_code,
          action: change_provider_action },
        { key: 'Course',
          value: course_option.course.name_and_code,
          action: change_course_action },
        { key: 'Full time or part time',
          value: course_option.study_mode.humanize,
          action: change_study_mode_action },
        location_row,
        accredited_body_details,
        { key: 'Qualification',
          value: qualification_text(course_option) },
        { key: 'Funding type',
          value: course_option.course.funding_type.humanize },
      ].compact_blank
    end

    def location_row
      return {} if @school_placement_auto_selected

      {
        key: t('school_placements.location'),
        value: course_option.site.name_and_address("\n"),
        action: change_location_action,
      }
    end

    def change_provider_action
      if available_providers.length > 1
        {
          href: edit_provider_interface_application_choice_course_providers_path(application_choice),
          visually_hidden_text: 'training provider',
        }
      else
        {}
      end
    end

    def change_course_action
      if available_courses.length > 1
        {
          href: edit_provider_interface_application_choice_course_courses_path(application_choice),
          visually_hidden_text: 'course details',
        }
      else
        {}
      end
    end

    def change_study_mode_action
      if course.full_time_or_part_time?
        {
          href: edit_provider_interface_application_choice_course_study_modes_path(application_choice),
          visually_hidden_text: 'if full time or part time',
        }
      else
        {}
      end
    end

    def change_location_action
      if available_course_options.length > 1
        {
          href: edit_provider_interface_application_choice_course_locations_path(application_choice),
          visually_hidden_text: 'location',
        }
      else
        {}
      end
    end
  end
end
