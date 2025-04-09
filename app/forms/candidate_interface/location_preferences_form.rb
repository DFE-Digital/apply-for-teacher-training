class CandidateInterface::LocationPreferencesForm
  include ActiveModel::Model

  attr_accessor :within, :name
  attr_reader :preference, :location_preference

  validates :within, presence: true
  validates :within, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :name, presence: true, length: { minimum: 2 }
  validate :location, if: -> { name.present? }

  def initialize(preference:, location_preference: nil, params: {})
    @preference = preference
    @location_preference = location_preference
    super(params)
  end

  def self.build_from_location_preference(preference:, location_preference:)
    new(
      preference:,
      location_preference: location_preference,
      params: {
        within: location_preference.within,
        name: location_preference.name,
      },
    )
  end

  def save
    return if invalid?

    if location_preference.present?
      location_preference.update(
        within:,
        name: name == location_preference.name ? name : suggested_location[:name],
        latitude: location_coordinates&.latitude,
        longitude: location_coordinates&.longitude,
        provider_id: name == location_preference.name ? location_preference.provider_id : nil,
      )
    else
      preference.location_preferences.create(
        within:,
        name: suggested_location[:name],
        latitude: location_coordinates&.latitude,
        longitude: location_coordinates&.longitude,
      )
    end
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
    @suggested_location ||= LocationSuggestions.new(name).call.first
  end

  def location
    if location_coordinates.nil?
      errors.add(:name, :invalid_location)
    end
  end
end
