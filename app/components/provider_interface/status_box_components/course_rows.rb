module ProviderInterface
  module StatusBoxComponents
    module CourseRows
      def course_rows(course_option:)
        rows = [
          {
            key: 'Provider',
            value: course_option.provider.name,
          },
          {
            key: 'Course',
            value: course_option.course.name_and_code,
          },
          {
            key: 'Study mode',
            value: course_option.full_time? ? 'Full time' : 'Part time',
          },
          {
            key: 'Location',
            value: course_option.site.name_and_address,
          },
        ]

        if course_option.course.accredited_provider.present?
          rows.push({
            key: 'Accredited body',
            value: course_option.course.accredited_provider.name,
          })
        end

        rows
      end
    end
  end
end
