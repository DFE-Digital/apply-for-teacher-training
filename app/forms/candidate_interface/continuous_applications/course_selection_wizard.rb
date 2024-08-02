module CandidateInterface
  module ContinuousApplications
    class CourseSelectionWizard < DfE::Wizard::Base
      # application_choice is only used in edit and update
      attr_accessor :current_application, :application_choice

      steps do
        [
          { do_you_know_the_course: CourseSelection::DoYouKnowTheCourseStep },
          { go_to_find_explanation: CourseSelection::GoToFindExplanationStep },
          { provider_selection: CourseSelection::ProviderSelectionStep },
          { which_course_are_you_applying_to: WhichCourseAreYouApplyingToStep },
          { duplicate_course_selection: DuplicateCourseSelectionStep },
          { reached_reapplication_limit: ReachedReapplicationLimitStep },
          { full_course_selection: FullCourseSelectionStep },
          { closed_course_selection: ClosedCourseSelectionStep },
          { course_study_mode: CourseStudyModeStep },
          { course_site: CourseSiteStep },
          { find_course_selection: FindCourseSelectionStep },
          { course_review: CourseReviewStep },
        ]
      end

      store CourseSelectionStore

      def logger
        DfE::Wizard::Logger.new(Rails.logger, if: -> { HostingEnvironment.test_environment? })
      end

      def completed?
        current_step.respond_to?(:completed?) && current_step.completed?
      end
    end
  end
end
