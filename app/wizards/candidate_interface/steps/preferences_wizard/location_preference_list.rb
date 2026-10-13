module CandidateInterface
  module Steps
    class PreferencesWizard::LocationPreferenceList
      include DfE::Wizard::Step

      validate :location_exists

      def location_exists
        errors.add(:base, :location_blank) if wizard.location_preferences.blank?
      end
    end
  end
end
