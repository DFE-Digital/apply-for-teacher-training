module CandidateInterface
  module CourseSelection
    class CourseSelectionWizard < DfE::Wizard::Base
      # application_choice is only used in edit and update
      attr_accessor :current_application, :application_choice

      steps do
        [
          { do_you_know_the_course: CourseSelection::DoYouKnowTheCourseStep },
          { go_to_find_explanation: CourseSelection::GoToFindExplanationStep },
          { provider_selection: CourseSelection::ProviderSelectionStep },
          { which_course_are_you_applying_to: CourseSelection::WhichCourseAreYouApplyingToStep },
          { duplicate_course_selection: CourseSelection::DuplicateCourseSelectionStep },
          { reached_reapplication_limit: CourseSelection::ReachedReapplicationLimitStep },
          { full_course_selection: CourseSelection::FullCourseSelectionStep },
          { closed_course_selection: CourseSelection::ClosedCourseSelectionStep },
          { course_study_mode: CourseSelection::CourseStudyModeStep },
          { course_site: CourseSelection::CourseSiteStep },
          { find_course_selection: CourseSelection::FindCourseSelectionStep },
          { course_review: CourseSelection::CourseReviewStep },
        ]
      end

      store CandidateInterface::CourseSelectionStore

      def logger
        DfE::Wizard::Logger.new(Rails.logger, if: -> { HostingEnvironment.test_environment? })
      end

      def completed?
        current_step.respond_to?(:completed?) && current_step.completed?
      end
    end
  end
end
