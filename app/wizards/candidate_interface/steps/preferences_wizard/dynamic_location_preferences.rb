module CandidateInterface
  module Steps
    class PreferencesWizard::DynamicLocationPreferences
      include DfE::Wizard::Step

      attribute :dynamic_location_preferences

      validates :dynamic_location_preferences, presence: true

      def self.permitted_params
        %i[dynamic_location_preferences]
      end
    end
  end
end
