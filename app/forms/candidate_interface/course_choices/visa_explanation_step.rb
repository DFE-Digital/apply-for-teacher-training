module CandidateInterface
  module CourseChoices
    class VisaExplanationStep < DfE::Wizard::Step
      attr_accessor :application_choice_id, :visa_explanation, :visa_explanation_details
      validates :application_choice_id, presence: true
      validates :visa_explanation, presence: true
      validates :visa_explanation_details, presence: true, if: -> { visa_explanation == 'other' }

      def self.permitted_params
        %i[application_choice_id visa_explanation visa_explanation_details]
      end

      def completed?
        true
      end

      def next_step
        :course_review
      end

      def next_step_path_arguments
        { application_choice_id: }
      end

      def previous_step
        :visa_expiry_interruption
      end

      def previous_step_path_arguments
        { application_choice_id: }
      end
    end
  end
end
