module CandidateInterface
  module Steps
    class PreferencesWizard::AddLocationPreference
      include DfE::Wizard::Step

      attribute :uuid, :string, default: -> { SecureRandom.uuid }
      attribute :within
      attribute :location_name

      validates :within, presence: true
      validates :within, numericality: { greater_than_or_equal_to: 0 }
      validates :location_name, presence: true, length: { minimum: 2 }
      validate :location, if: -> { location_name.present? }

      def self.permitted_params
        %i[uuid within location_name]
      end

    private

      def location_coordinates
        # Validating if a location is an actual location is hard
        # Geocoder.search can return places that are not actually real locations
        # So we rely on the suggestions, which suggests real locations based on inputted string
        # And assume the user meant the first suggestions. This stops the user inputing '123121'
        # But allows them to input M20 for example. Which is a real place.
        # The suggestions api call will be cached, the view uses it, so when the user inputs we will cache the results

        return unless suggested_location

        Geocoder.search(suggested_location[:place_id], google_place_id: true).first
      end

      def suggested_location
        @suggested_location ||= LocationSuggestions.new(location_name).call.first
      end

      def location
        if location_coordinates.nil?
          errors.add(:location_name, :invalid_location)
        end
      end
    end
  end
end
