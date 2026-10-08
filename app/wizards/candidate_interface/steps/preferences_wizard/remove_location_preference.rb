module CandidateInterface
  module Steps
    class PreferencesWizard::RemoveLocationPreference
      include DfE::Wizard::Step

      attribute :uuid
      attribute :location_name
    end
  end
end
