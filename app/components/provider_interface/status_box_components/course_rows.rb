module ProviderInterface
  module StatusBoxComponents
    module CourseRows
      def course_rows(course_option:)
        [
          {
            key: 'Provider',
            value: course_option.provider.name,
          },
          {
            key: 'Course',
            value: course_option.course.name_and_code,
          },
          {
            key: 'Location',
            value: course_option.site.name_and_address,
          },
        ]
      end
    end
  end
end
