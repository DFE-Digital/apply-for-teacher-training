module CandidateInterface
  module CourseChoices
    class DoYouKnowTheCourseStep < DfE::Wizard::Step
      attr_accessor :answer
      validates :answer, presence: true

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
