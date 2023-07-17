module CandidateInterface
  class DoYouKnowTheCourseStep < DfE::WizardStep
  end

  class CourseSelectionWizard < DfE::Wizard
    steps do
      [
        { do_you_know_the_course: CandidateInterface::DoYouKnowTheCourseStep },
        { go_to_find: :none },
        { provider_selection: :other },
      ]
    end
  end
end
