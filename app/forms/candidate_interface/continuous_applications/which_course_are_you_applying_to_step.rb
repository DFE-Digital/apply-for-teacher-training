module CandidateInterface
  module ContinuousApplications
    class WhichCourseAreYouApplyingToStep < DfE::WizardStep
      include Concerns::CourseSelectionStepHelper
      attr_accessor :provider_id, :course_id
      validates :provider_id, :course_id, presence: true

      def self.permitted_params
        %i[provider_id course_id]
      end

      def available_courses
        @available_courses ||= GetAvailableCoursesForProvider.new(provider).call
      end

      def dropdown_available_courses
        ::CandidateInterface::PickCourseForm.new(provider_id:).dropdown_available_courses
      end

      def previous_step
        :provider_selection
      end

      def next_step
        return :course_review if completed?

        if multiple_study_modes?
          :course_study_mode
        elsif multiple_sites?
          :course_site
        end
      end

      def next_step_path_arguments
        if completed?
          { application_choice_id: application_choice.id }
        elsif multiple_study_modes?
          { provider_id:, course_id: }
        elsif multiple_sites?
          { provider_id:, course_id:, study_mode: }
        end
      end

      def study_mode
        course.available_study_modes_with_vacancies.first
      end

      def completed?
        !multiple_study_modes? && !multiple_sites?
      end
    end
  end
end
