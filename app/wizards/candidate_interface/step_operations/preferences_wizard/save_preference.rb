module CandidateInterface
  module StepOperations
    class PreferencesWizard::SavePreference < Base
      def execute
        debugger
        ActiveRecord::Base.transaction do
          current_application.preferences.create!(
            dynamic_location_preferences: state_store.dynamic_location_preferences,
            funding_type: state_store.funding_type,
            opt_out_reason: state_store.opt_out_reason,
            pool_status: state_store.pool_status,
            status: 'published',
            training_locations: state_store.training_locations,
            location_preferences:,
          )
        end
        { success: true }
      end

    private

      def location_preferences
        state_store.location_preferences.map do |lp|
          location_name = lp[:location_name]
          CandidateLocationPreference.new(
            within: lp[:within],
            name: location_name,
            latitude: location_coordinates(location_name)&.latitude,
            longitude: location_coordinates(location_name)&.longitude,
          )
        end
      end


      def location_coordinates(location_name)
        # Validating if a location is an actual location is hard
        # Geocoder.search can return places that are not actually real locations
        # So we rely on the suggestions, which suggests real locations based on inputted string
        # And assume the user meant the first suggestions. This stops the user inputing '123121'
        # But allows them to input M20 for example. Which is a real place.
        # The suggestions api call will be cached, the view uses it, so when the user inputs we will cache the results

        location = suggested_location(location_name)
        return unless location

        Geocoder.search(location[:place_id], google_place_id: true).first
      end

      def suggested_location(name)
        @suggested_location ||= LocationSuggestions.new(name).call.first
      end
    end
  end
end
