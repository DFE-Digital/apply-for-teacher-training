module CandidateInterface
  module Steps
    class PreferencesWizard::AddLocationPreference
      include DfE::Wizard::Step

      attribute :uuid, :string, default: -> { SecureRandom.uuid }
      attribute :within
      attribute :location_name

      validates :within, presence: true
      validates :location_name, presence: true

      def self.permitted_params
        %i[uuid within location_name]
      end
    end
  end
end
