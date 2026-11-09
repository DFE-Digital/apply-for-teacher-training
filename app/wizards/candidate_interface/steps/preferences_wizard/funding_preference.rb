module CandidateInterface
  module Steps
    class PreferencesWizard::FundingPreference
      include DfE::Wizard::Step

      attribute :funding_type

      FUNDING_TYPE_OPTIONS = %w[fee salary].freeze

      validates :funding_type, inclusion: { in: FUNDING_TYPE_OPTIONS }

      def self.permitted_params
        %i[funding_type]
      end
    end
  end
end
