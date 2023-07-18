module CandidateInterface
  class DoYouKnowTheCourseStep < DfE::WizardStep
    attr_accessor :answer
    validates :answer, presence: true

    def self.permitted_params
      [:answer]
    end

    def next_step
      if answer == 'yes'
        :provider_selection
      elsif answer == 'no'
        :go_to_find_explanation
      end
    end
  end

  class ProviderSelectionStep < DfE::WizardStep
  end

  class GoToFindExplanationStep < DfE::WizardStep
  end

  class CourseSelectionWizard < DfE::Wizard
    steps do
      [
        { do_you_know_the_course: CandidateInterface::DoYouKnowTheCourseStep },
        { go_to_find_explanation: CandidateInterface::GoToFindExplanationStep },
        { provider_selection: CandidateInterface::ProviderSelectionStep },
      ]
    end
  end
end
