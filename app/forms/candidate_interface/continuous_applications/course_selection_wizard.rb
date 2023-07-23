module CandidateInterface
  module ContinuousApplications
    class CourseSelectionStore < DfE::WizardStore
      def save
        # on create
        # on edit
        # model update (replace)
        true
      end
    end

    class CourseSelectionWizard < DfE::Wizard
      steps do
        [
          { do_you_know_the_course: DoYouKnowTheCourseStep },
          { go_to_find_explanation: GoToFindExplanationStep },
          { provider_selection: ProviderSelectionStep },
          { which_course_are_you_applying_to: WhichCourseAreYouApplyingToStep },
          { course_study_mode: CourseStudyModeStep },
          { course_site: CourseSiteStep },
          { course_review: CourseReviewStep },
        ]
      end

      store CourseSelectionStore

      def logger
        DfE::Wizard::Logger.new(Rails.logger, if: -> { Rails.env.development? })
      end
    end
  end
end
