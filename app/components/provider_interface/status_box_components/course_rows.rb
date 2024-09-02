module ProviderInterface
  module StatusBoxComponents
    module CourseRows
      def course_rows(application_choice:)
        rows = [
          {
            key: 'Provider',
            value: application_choice.course_option.provider.name,
          },
          {
            key: 'Course',
            value: application_choice.course_option.course.name_and_code,
          },
          {
            key: 'Full time or part time',
            value: application_choice.course_option.study_mode.humanize,
          },
          {
            key: location_key(application_choice),
            value: application_choice.course_option.site.name_and_address,
          },
        ]

        if application_choice.course_option.course.accredited_provider.present?
          rows.push({
            key: 'Accredited body',
            value: application_choice.course_option.course.accredited_provider.name,
          })
        end

        rows
      end

      def location_key(application_choice)
        text = 'not ' if application_choice.school_placement_auto_selected?
        "Location (#{text}selected by candidate)"
      end
    end
  end
end
