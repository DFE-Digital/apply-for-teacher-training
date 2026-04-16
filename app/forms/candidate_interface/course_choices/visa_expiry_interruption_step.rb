module CandidateInterface
  module CourseChoices
    class VisaExpiryInterruptionStep < DfE::Wizard::Step
      include Rails.application.routes.url_helpers
      include CandidateInterface::Concerns::CourseSelectionStepHelper

      attr_accessor :application_choice_id
      validates :application_choice_id, presence: true

      def self.permitted_params
        %i[application_choice_id]
      end

      def next_step
        :visa_explanation
      end

      def application_choice
        @application_choice ||= @wizard.application_choice
      end

      def course
        @course ||= application_choice.current_course
      end

      def provider
        @provider ||= course.provider
      end

      def next_step_path_arguments
        { application_choice_id: }
      end

      def previous_step
        if multiple_study_modes?
          :course_study_mode
        elsif multiple_sites?
          :course_site
        else
          :which_course_are_you_applying_to
        end
      end

      def previous_step_path(_)
        # The previous paths on this step need to go to edit pages, not new
        # That's why we need to override this method
        if multiple_study_modes?
          candidate_interface_edit_course_choices_course_study_mode_path(
            application_choice_id,
            course.id,
          )
        elsif multiple_sites?
          candidate_interface_edit_course_choices_course_site_path(
            application_choice_id,
            course.id,
            application_choice.current_course_option.study_mode,
          )
        else
          candidate_interface_edit_course_choices_which_course_are_you_applying_to_path(
            application_choice,
          )
        end
      end
    end
  end
end
