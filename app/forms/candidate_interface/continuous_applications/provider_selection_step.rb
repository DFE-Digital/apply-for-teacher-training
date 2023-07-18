module CandidateInterface
  module ContinuousApplications
    class ProviderSelectionStep < DfE::WizardStep
      attr_accessor :provider_id
      validates :provider_id, presence: true

      def self.permitted_params
        [:provider_id]
      end

      def next_step
        :which_course_are_you_applying_to
      end
    end
  end
end
