module CandidateInterface
  module ContinuousApplications
    class CourseSelectionWizard < DfE::Wizard
      steps do
        [
          { do_you_know_the_course: DoYouKnowTheCourseStep },
          { go_to_find_explanation: GoToFindExplanationStep },
          { provider_selection: ProviderSelectionStep },
        ]
      end
    end
  end
end
