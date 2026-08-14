module CandidateInterface
  module CourseChoices
    class GoToFindExplanationStep
      include DfE::Wizard::Step
      def previous_step
        :do_you_know_the_course
      end
    end
  end
end
