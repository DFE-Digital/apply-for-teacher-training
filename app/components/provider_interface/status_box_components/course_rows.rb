module ProviderInterface
  module StatusBoxComponents
    module CourseRows
      def course_rows(course_option:)
        [
          {
            key: 'Provider',
            value: course_option.provider.name,
            change_path: change_path(:provider), action: 'training provider'
          },
          {
            key: 'Course',
            value: course_option.course.name_and_code,
            change_path: change_path(:course), action: 'course'
          },
          {
            key: 'Location',
            value: course_option.site.name_and_address,
            change_path: change_path(:course_option), action: 'location'
          },
        ]
      end
    end
  end
end
