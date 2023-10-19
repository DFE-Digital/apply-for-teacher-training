module CandidateInterface
  module ContinuousApplications
    class CourseReviewComponent < CourseChoicesReviewComponent
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
        @editable = false
      end

      def rows
        [
          course_row(application_choice),
          application_number_row(application_choice),
          study_mode_row(application_choice),
          location_row(application_choice),
          type_row(application_choice),
          course_length_row(application_choice),
          start_date_row(application_choice),
          degree_required_row(application_choice),
          gcse_required_row(application_choice),
        ].compact
      end

      def course_row(application_choice)
        {
          key: 'Course',
          value: course_row_value(application_choice),
        }
      end

      def location_row(application_choice)
        {
          key: 'Location',
          value: "#{application_choice.current_site.name}\n#{application_choice.current_site.full_address}",
        }
      end
    end
  end
end
