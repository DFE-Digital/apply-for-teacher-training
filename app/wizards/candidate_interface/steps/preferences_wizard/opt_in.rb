module CandidateInterface
  module Steps
    class PreferencesWizard::OptIn
      include DfE::Wizard::Step

      attribute :pool_status
      attribute :opt_out_reason

      validates :pool_status, presence: true
      validates :opt_out_reason, word_count: { maximum: 200 }, if: -> { pool_status == 'opt_out' }

      def self.permitted_params
        %i[pool_status opt_out_reason]
      end
    end
  end
end
