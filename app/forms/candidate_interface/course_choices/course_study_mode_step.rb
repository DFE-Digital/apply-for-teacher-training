module CandidateInterface
  module CourseChoices
    class CourseStudyModeStep < DfE::Wizard::Step
      include CandidateInterface::Concerns::CourseSelectionStepHelper

      attr_accessor :provider_id, :course_id, :study_mode

      validates :study_mode, presence: true

      def self.permitted_params
        %i[provider_id course_id study_mode]
      end

      def previous_step
        :which_course_are_you_applying_to
      end

      def next_step
        if completed?
          :course_review
        else
          :course_site
        end
      end

      def next_step_path_arguments
        if completed?
          { application_choice_id: application_choice.id }
        else
          { provider_id:, course_id:, study_mode: }
        end
      end

      def edit_next_step_path_arguments
        { application_choice_id: application_choice.id, course_id:, study_mode: }
      end

      def completed?
        !multiple_sites?
      end

      def previous_step_path_arguments
        { provider_id: }
      end
    end
  end
end
