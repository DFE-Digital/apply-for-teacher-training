module CandidateInterface
  module Steps
    class CourseSelectionWizard::VisaExplanation
      include DfE::Wizard::Step

      attribute :visa_explanation
      attribute :visa_explanation_details
      validates :visa_explanation, presence: true
      validates :visa_explanation_details, presence: true, if: -> { visa_explanation == 'other' }

      def self.permitted_params
        %i[visa_explanation visa_explanation_details]
      end
    end
  end
end
