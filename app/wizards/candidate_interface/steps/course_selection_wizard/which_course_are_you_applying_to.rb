module CandidateInterface
  module Steps
    class CourseSelectionWizard::WhichCourseAreYouApplyingTo
      include DfE::Wizard::Step
      include CandidateInterface::Concerns::CourseSelectionStepHelper
      include FreeTextInputHelper

      attribute :provider_id
      attribute :course_id
      attribute :course_id_raw
      alias_attribute :value, :course_id
      alias_attribute :raw_input, :course_id_raw
      alias_attribute :valid_options, :select_course_options

      validates :course_id, presence: true
      validate :no_free_text_input

      validates_with CourseSelectionValidator, on: :course_choice

      def self.permitted_params
        %i[provider_id course_id course_id_raw]
      end

      def no_free_text_input
        errors.add(:course_id, :blank) if invalid_raw_data?
      end

      def available_courses
        @available_courses ||= GetAvailableCoursesForProvider.new(provider).call
      end

      def radio_available_courses
        ::CandidateInterface::PickCourseForm.new(provider_id:, available_courses:).radio_available_courses
      end

      def provider
        wizard.provider
      end
    end
  end
end
