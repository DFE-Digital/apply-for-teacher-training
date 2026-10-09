module CandidateInterface
  module Steps
    class PreferencesWizard::TrainingLocations
      include DfE::Wizard::Step

      attribute :training_locations

      validates :training_locations, presence: true

      def self.permitted_params
        %i[training_locations]
      end
    end
  end
end
