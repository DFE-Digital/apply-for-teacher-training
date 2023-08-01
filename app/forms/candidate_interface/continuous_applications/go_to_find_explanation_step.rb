module CandidateInterface
  module ContinuousApplications
    class GoToFindExplanationStep < DfE::WizardStep
      def previous_step
        :do_you_know_the_course
      end
    end
  end
end
