module CandidateInterface
  module StepOperations
    class PreferencesWizard::SavePreference < Base
      delegate :training_locations_anywhere?, :training_locations_specific?, :preference, to: :wizard

      def execute
        return { success: true } if current_step_name == :opt_in && wizard.opt_in?

        ActiveRecord::Base.transaction do
          if preference.blank?
            current_application.preferences.create!(**preference_attributes)
          else
            preference.update!(**preference_attributes)
          end
          wizard.clear_state
        end
        state_store.write(current_application_id: wizard.current_application.id)

        { success: true }
      end

    private

      def preference_attributes
        {
          status: 'published',
          dynamic_location_preferences: training_locations_specific? ? state_store.dynamic_location_preferences : nil,
          funding_type: state_store.funding_type,
          opt_out_reason: state_store.opt_out_reason,
          pool_status: state_store.pool_status,
          training_locations: state_store.training_locations,
          location_preferences:,
        }
      end

      def location_preferences
        return [] if training_locations_anywhere?

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
