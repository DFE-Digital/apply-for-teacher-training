module CandidateInterface
  module ContinuousApplications
    class CourseSelectionStore < DfE::WizardStore
      delegate :current_application, to: :wizard
      attr_accessor :application_choice

      def save
        return :skipped unless wizard.completed?

        @application_choice = current_application.application_choices.new
        @application_choice.configure_initial_course_choice!(course_option)
        @application_choice
      end

      def course_option
        if current_step.multiple_study_modes?
          available_course_options.find_by(study_mode: current_step.study_mode)
        elsif current_step.multiple_sites?
          available_course_options.find(current_step.course_option_id)
        else
          available_course_options.first
        end
      end

      def available_course_options
        current_step.course.course_options.available
      end
    end
  end
end
