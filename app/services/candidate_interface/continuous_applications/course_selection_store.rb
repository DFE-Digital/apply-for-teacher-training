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
          current_step.course.course_options.available.find_by(study_mode: current_step.study_mode)
        elsif current_step.multiple_sites?
          current_step.course.course_options.available.find(current_step.course_option_id)
        else
          current_step.course.course_options.available.first
        end
      end
    end
  end
end
