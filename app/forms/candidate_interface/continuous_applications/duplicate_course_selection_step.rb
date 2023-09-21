module CandidateInterface
  module ContinuousApplications
    class DuplicateCourseSelectionStep < DfE::WizardStep
      include Concerns::CourseSelectionStepHelper
      attr_accessor :provider_id, :course_id
      validates :provider_id, :course_id, presence: true

      def self.permitted_params
        %i[provider_id course_id]
      end

      def previous_step
        :which_course_are_you_applying_to
      end

      def next_step; end

      def previous_step_path_arguments
        { provider_id: provider_id }
      end

      def study_mode
        course.available_study_modes_with_vacancies.first
      end
    end
  end
end
