module CandidateInterface
  module Steps
    class CourseSelectionWizard::WhichCourseAreYouApplyingTo
      include DfE::Wizard::Step
      include FreeTextInputHelper

      attribute :course_id
      attribute :course_id_raw
      alias_attribute :value, :course_id
      alias_attribute :raw_input, :course_id_raw
      alias_attribute :valid_options, :select_course_options

      validates :course_id, presence: true
      validate :no_free_text_input

      delegate :provider, :provider_id, to: :wizard

      def self.permitted_params
        %i[course_id course_id_raw]
      end

      def no_free_text_input
        errors.add(:course_id, :blank) if invalid_raw_data?
      end

      def available_courses
        @available_courses ||= GetAvailableCoursesForProvider.new(provider).call
      end

      delegate :radio_available_courses, to: :pick_course_form

      def dropdown_available_courses
        @dropdown_available_courses ||= pick_course_form.dropdown_available_courses
      end

      def select_course_options
        dropdown_available_courses.pluck(:name, :id).unshift([nil, nil])
      end

      def completed?
        !wizard.multiple_study_modes? && !wizard.multiple_sites? && valid_course_choice
      end

    private

      def pick_course_form
        @pick_course_form ||= ::CandidateInterface::PickCourseForm.new(provider_id:, available_courses:)
      end

      def valid_course_choice
        @valid_course_choice ||= !wizard.duplicate_course? && !wizard.reapplication_limit_reached? && !wizard.course_unavailable? && !wizard.course_closed?
      end
    end
  end
end
