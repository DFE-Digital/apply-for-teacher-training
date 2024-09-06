module CandidateInterface
  module CourseChoices
    class GoToFindExplanationStep < DfE::Wizard::Step
      def self.route_name
        'candidate_interface_course_choices_go_to_find_explanation'
      end

      def previous_step
        :do_you_know_the_course
      end
    end
  end
end
