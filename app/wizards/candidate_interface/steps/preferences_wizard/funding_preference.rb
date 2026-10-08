module CandidateInterface
  module Steps
    class PreferencesWizard::FundingPreference
      include DfE::Wizard::Step

      attribute :funding_type

      validates :funding_type, presence: true

      def self.permitted_params
        %i[funding_type]
      end
    end
  end
end
