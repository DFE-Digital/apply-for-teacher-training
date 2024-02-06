module SupportInterface
  module ApplicationForms
    class PickCourseForm
      include ActiveModel::Model

      attr_accessor :course_code, :application_form_id, :candidate_id, :course_option_id

      validates :course_option_id, presence: true
      validates :application_form_id, presence: true
      validates :course_code, presence: true
      validate :course_exists, on: :save

      RadioOption = Struct.new(
        :course_option_id,
        :provider_name,
        :provider_code,
        :course_name,
        :course_code,
        :site_name,
        :study_mode,
        keyword_init: true,
      )

      def course_options
        @course_options ||= course_radio_options_for(courses)
      end

      def course_options_for_provider(provider)
        course_radio_options_for(courses_for_provider(provider))
      end

      def course_options_for_other_providers(provider)
        course_radio_options_for(courses_for_other_providers(provider))
      end

      def applicant_name
        application_form.full_name
      end

      def create_radio_option(course_option)
        RadioOption.new(
          course_option_id: course_option.id,
          provider_name: course_option.provider.name,
          provider_code: course_option.provider.code,
          course_name: course_option.course.name,
          course_code: course_option.course.code,
          site_name: course_option.site.name,
          study_mode: course_option.study_mode.humanize,
        )
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

      def courses_for_provider(provider)
        return Course.none if provider.blank?

        Course
          .current_cycle
          .includes(course_options: [:site])
          .where(provider_id: provider.id)
          .or(Course.current_cycle.where(accredited_provider_id: provider.id))
          .where(code: sanitize(course_code))
      end

      def courses_for_other_providers(provider)
        return Course.none if provider.blank?

        courses - courses_for_provider(provider)
      end

      def course_radio_options_for(courses)
        courses.map do |course|
          course.course_options.map { |course_option| create_radio_option(course_option) }
        end.flatten.sort_by(&:course_name)
      end

      def sanitize(course_code)
        course_code&.strip&.upcase
      end

      def existing_course_ids
        application_form
          .application_choices
          .map(&:course_option)
          .pluck(:course_id)
      end

      def course_exists
        return if Course.exists?(code: sanitize(course_code))

        errors.add(:course_option_id, 'This course does not exist')
      end
    end
  end
end
