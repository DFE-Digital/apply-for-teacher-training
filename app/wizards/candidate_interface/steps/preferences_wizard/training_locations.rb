module CandidateInterface
  module Steps
    class PreferencesWizard::TrainingLocations
      include DfE::Wizard::Step

      attribute :training_locations

      LOCATION_OPTIONS = %w[anywhere specific].freeze

      validates :training_locations, inclusion: { in: LOCATION_OPTIONS }

      def self.permitted_params
        %i[training_locations]
      end
    end
  end
end
