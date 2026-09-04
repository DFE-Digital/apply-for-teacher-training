module CandidateInterface
  module Steps
    class CourseSelectionWizard::VisaExplanation
      include DfE::Wizard::Step

      attribute :visa_explanation
      attribute :visa_explanation_details
      validates :visa_explanation, presence: true
      validates :visa_explanation_details, presence: true, if: -> { other_visa_explanation? }

      def self.permitted_params
        %i[visa_explanation visa_explanation_details]
      end

      def other_visa_explanation?
        visa_explanation == 'other'
      end
    end
  end
end
