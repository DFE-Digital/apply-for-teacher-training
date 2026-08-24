module CandidateInterface
  module StepOperations
    class CourseSelectionWizard::CreateApplicationChoice < CourseSelectionWizard::Base
      delegate :completed?, to: :current_step

      def execute
        return unless completed?

        save_application_choice(application_choice)
        wizard.application_choice = application_choice
        wizard.state_store.write(application_choice_id: application_choice.id)

        { success: true, application_choice_id: application_choice.id }
      end

    private

      def application_choice
        @application_choice ||= wizard.application_choice ||
                                ApplicationChoice.find_by(id: wizard.state_store[:application_choice_id]) ||
                                current_application.application_choices.new
      end

      def course_option
        case current_step_name
        when :course_study_mode
          main_site_or_first_course_option(
            available_course_options.where(study_mode: current_step.study_mode),
          )
        when :course_site
          available_course_options.find(current_step.course_option_id)
        else
          main_site_or_first_course_option(available_course_options)
        end
      end

      def available_course_options
        wizard.course.course_options.available
      end

      def save_application_choice(choice)
        choice.tap do |c|
          c.configure_initial_course_choice!(course_option)

          if choice.provider
            choice.update(school_placement_auto_selected: !choice.provider.selectable_school?)
          end
        end
      end

      def main_site_or_first_course_option(records)
        records.find do |course_option|
          course_option.site.main_site?
        end.presence || records.first
      end
    end
  end
end
