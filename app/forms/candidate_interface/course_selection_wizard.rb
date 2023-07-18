module CandidateInterface
  class DoYouKnowTheCourseStep < DfE::WizardStep
    attr_accessor :answer
    validates :answer, presence: true

    def self.permitted_params
      [:answer]
    end
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
