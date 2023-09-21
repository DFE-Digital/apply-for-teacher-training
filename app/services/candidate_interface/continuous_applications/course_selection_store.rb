module CandidateInterface
  module ContinuousApplications
    class CourseSelectionStore < DfE::WizardStore
      delegate :current_step_name, :current_application, to: :wizard
      attr_accessor :application_choice

      def save
        return false unless wizard.valid_step?
        return true unless wizard.completed?

        @application_choice = save_application_choice(
          current_application.application_choices.new,
        )
      end

      def update
        return false unless wizard.valid_step?

        @application_choice = save_application_choice(
          wizard.application_choice,
        )
      end

      def course_option
        case current_step_name
        when :course_study_mode
          available_course_options.find_by(study_mode: current_step.study_mode)
        when :course_site
          available_course_options.find(current_step.course_option_id)
        else
          available_course_options.first
        end
      end

      def available_course_options
        current_step.course.course_options.available
      end

      def save_application_choice(choice)
        choice.tap do
          choice.configure_initial_course_choice!(course_option)
        end
      end
    end
  end
end
