module SupportInterface
  module ApplicationForms
    class PickCourseForm
      include ActiveModel::Model

      attr_accessor :course_code, :application_form_id, :candidate_id, :course_option_id

      validates :course_option_id, presence: true
      validates :application_form_id, presence: true
      validates :course_code, presence: true
      validate :course_is_open_on_apply, on: :save

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
        return @course_options if @course_options

        course_options = courses.map do |course|
          course.course_options
                .available
                .reject { |course_option| existing_course_ids.include?(course_option.course_id) }
                .map {  |course_option| create_radio_option(course_option) }
        end.flatten

        sorted_course_options = course_options.sort_by(&:course_name)
        @course_options = sorted_course_options
      end

      def course_options_for_provider(provider)
        course_options = courses_for_provider(provider).map do |course|
          course.course_options
                .available
                .reject { |course_option| existing_course_ids.include?(course_option.course_id) }
                .map {  |course_option| create_radio_option(course_option) }
        end.flatten

        sorted_course_options = course_options.sort_by(&:course_name)
        @course_options = sorted_course_options
      end

      def unavailable_courses
        courses.select { |course| course.course_options.all?(&:no_vacancies?) }
      end

      def save
        return false unless valid?(:save)

        SupportInterface::AddCourseChoiceAfterSubmission.new(
          application_form: application_form,
          course_option: course_option,
        ).call
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
          .open_on_apply
          .includes(course_options: [:site])
          .where(code: sanitize(course_code))
      end

      def courses_for_provider(provider)
        return [] if provider.blank?

        Course
          .current_cycle
          .open_on_apply
          .includes(course_options: [:site])
          .where(provider_id: provider.id)
          .or(Course.where(accredited_provider_id: provider.id))
          .where(code: sanitize(course_code))
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

      def course_is_open_on_apply
        return if Course.open_on_apply.exists?(code: sanitize(course_code))

        errors.add(:course_option_id, 'This course is not open on the Apply service')
      end
    end
  end
end
