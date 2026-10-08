module CandidateInterface
  module StepOperations
    class PreferencesWizard::AssignLocationPreference < Base
      def execute
        location_preference_list = state_store[:location_preference_list] || []

        if location_preference_list.blank? || find_location_preference(list: location_preference_list, uuid: state_store.uuid).blank?
          location_preference_list << {
            uuid: state_store.uuid,
            within: state_store.within,
            location_name: state_store.location_name,
          }
        else
          location_preference = find_location_preference(list: location_preference_list, uuid: state_store.uuid)
          location_preference[:within] = state_store.within
          location_preference[:location_name] = state_store.location_name
        end
        state_store.write(location_preference_list:, within: nil, location_name: nil, uuid: nil)
        { success: true }
      end

    private

      def find_location_preference(list:, uuid:)
        @find_location_preference ||= list.find{ |lp| lp[:uuid] == uuid }
      end
    end
  end
end
