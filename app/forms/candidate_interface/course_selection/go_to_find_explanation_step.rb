module CandidateInterface
  module CourseSelection
    class GoToFindExplanationStep < DfE::Wizard::Step
      def self.route_name
        'candidate_interface_continuous_applications_go_to_find_explanation'
      end

      def previous_step
        :do_you_know_the_course
      end
    end
  end
end
