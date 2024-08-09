module CandidateInterface
  module CourseSelection
    class DoYouKnowTheCourseStep < DfE::Wizard::Step
      attr_accessor :answer
      validates :answer, presence: true

      def self.route_name
        'candidate_interface_course_choices_do_you_know_the_course'
      end

      def self.permitted_params
        [:answer]
      end

      def previous_step
        :first_step
      end

      def next_step
        if answer == 'yes'
          :provider_selection
        elsif answer == 'no'
          :go_to_find_explanation
        end
      end
    end
  end
end
