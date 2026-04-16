module CandidateInterface
  module CourseChoices
    class CourseSelectionWizard < DfE::Wizard::Base
      # application_choice is only used in edit and update
      attr_accessor :current_application, :application_choice

      steps do
        [
          { do_you_know_the_course: CourseChoices::DoYouKnowTheCourseStep },
          { go_to_find_explanation: CourseChoices::GoToFindExplanationStep },
          { provider_selection: CourseChoices::ProviderSelectionStep },
          { which_course_are_you_applying_to: CourseChoices::WhichCourseAreYouApplyingToStep },
          { duplicate_course_selection: CourseChoices::DuplicateCourseSelectionStep },
          { reached_reapplication_limit: CourseChoices::ReachedReapplicationLimitStep },
          { full_course_selection: CourseChoices::FullCourseSelectionStep },
          { closed_course_selection: CourseChoices::ClosedCourseSelectionStep },
          { course_study_mode: CourseChoices::CourseStudyModeStep },
          { course_site: CourseChoices::CourseSiteStep },
          { find_course_selection: CourseChoices::FindCourseSelectionStep },
          { visa_expiry_interruption: CourseChoices::VisaExpiryInterruptionStep },
          { visa_explanation: CourseChoices::VisaExplanationStep },
          { course_review: CourseChoices::CourseReviewStep },
        ]
      end

      store CourseSelectionStore

      def update_visa_explanation
        return false unless valid_step? && current_step_name == :visa_explanation

        application_choice.update(
          visa_explanation: step_params[:visa_explanation],
          visa_explanation_details: step_params[:visa_explanation_details].presence,
        )
      end

      def logger
        DfE::Wizard::Logger.new(Rails.logger, if: -> { HostingEnvironment.test_environment? })
      end

      def completed?
        current_step.respond_to?(:completed?) && current_step.completed?
      end
    end
  end
end
