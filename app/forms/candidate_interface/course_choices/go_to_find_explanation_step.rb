module CandidateInterface
  module CourseChoices
    class GoToFindExplanationStep < DfE::Wizard::Step
      def previous_step
        :do_you_know_the_course
      end
    end
  end
end
