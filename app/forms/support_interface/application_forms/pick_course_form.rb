module SupportInterface
  module ApplicationForms
    class PickCourseForm
      include ActiveModel::Model

      attr_accessor :course_code, :application_form_id, :candidate_id, :course_option_id

      validates :course_option_id, presence: true
      validates :application_form_id, presence: true
      validates :course_code, presence: true

      RadioOption = Struct.new(:course_option_id, :course_name, :course_code, :site_name)

      def course_options
        return @course_options if @course_options

        course_options = courses.map { |course|
          course.course_options
                .available
                .reject { |course_option| existing_course_ids.include?(course_option.course_id) }
                .map { |course_option| RadioOption.new(course_option.id, course.name, course.code, course_option.site.name) }
        }.flatten

        sorted_course_options = course_options.sort_by(&:course_name)
        @course_options = sorted_course_options
      end

      def save
        return false unless valid?

        SupportInterface::AddCourseChoiceAfterSubmission.new(
          application_form: application_form,
          course_option: course_option,
        ).call
      end

      def applicant_name
        application_form.full_name
      end

    private

      def application_form
        @application_form ||= ApplicationForm
          .includes(application_choices: [:course_option])
          .find(application_form_id)
      end

      def course_option
        @course_option ||= CourseOption.find(course_option_id)
      end

      def courses
        Course
          .current_cycle
          .includes(course_options: [:site])
          .where(code: sanitize(course_code))
      end

      def sanitize(course_code)
        course_code.strip.upcase
      end

      def existing_course_ids
        application_form
          .application_choices
          .map(&:course_option)
          .pluck(:course_id)
      end
    end
  end
end
