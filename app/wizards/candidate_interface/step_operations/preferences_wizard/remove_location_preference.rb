module CandidateInterface
  module StepOperations
    class PreferencesWizard::RemoveLocationPreference < Base
      def execute
        location_preference_list = state_store[:location_preference_list]
        location_preference_list.delete_if { |lp| lp[:uuid] == state_store.uuid }
        state_store.write(location_preference_list:, within: nil, location_name: nil, uuid: nil)
        { success: true }
      end
    end
  end
end
