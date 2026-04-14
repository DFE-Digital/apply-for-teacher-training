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
          if application_choice.visa_expires_soon?
            :visa_expiry_interruption
          else
            :course_review
          end
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

      # When editing an application choice, we want to load the show path for
      # some steps that don't have an edit action / template
      def next_edit_step_path(next_step_klass)
        classes_without_edit = [VisaExpiryInterruptionStep]
        return next_step_path(next_step_klass) if classes_without_edit.include?(next_step_klass)

        super
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
