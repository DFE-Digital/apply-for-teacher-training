module CandidateInterface
  module ContinuousApplications
    class CourseSelectionWizard < DfE::Wizard
      logger :enabled, if: -> { Rails.env.development? }
      steps do
        [
          { do_you_know_the_course: DoYouKnowTheCourseStep },
          { go_to_find_explanation: GoToFindExplanationStep },
          { provider_selection: ProviderSelectionStep },
          { which_course_are_you_applying_to: WhichCourseAreYouApplyingToStep },
        ]
      end
    end
  end
end
