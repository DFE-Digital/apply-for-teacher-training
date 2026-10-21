module CandidateInterface
  module StepOperations
    class PreferencesWizard::AssignDefaultLocationPreferences < Base
      DEFAULT_RADIUS = 10

      def execute
        return { success: true } if wizard.location_preferences.present? || wizard.training_locations_anywhere?

        location_preference_list = []

        application_form = wizard.current_application
        sites = application_form.application_choices.map(&:site)

        unless application_form.international_address? || application_form.geocode.nil?
          location_preference_list << {
            uuid: SecureRandom.uuid,
            location_name: application_form.postcode,
            within: DEFAULT_RADIUS,
            latitude: application_form.geocode.first,
            longitude: application_form.geocode.last,
          }
        end

        sites.each do |site|
          next unless site.geocoded?

          location_preference_list << {
            uuid: SecureRandom.uuid,
            location_name: site.postcode,
            within: DEFAULT_RADIUS,
            latitude: site.latitude,
            longitude: site.longitude,
            provider_id: site.provider_id,
          }
        end

        state_store.write(location_preference_list:)
        { success: true }
      end
    end
  end
end
