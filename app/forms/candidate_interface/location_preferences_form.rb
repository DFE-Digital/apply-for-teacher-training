class CandidateInterface::LocationPreferencesForm
  include ActiveModel::Model

  attr_accessor :within, :name
  attr_reader :preference, :location_preference

  validates :within, presence: true
  validates :name, presence: true
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
        name:,
        latitude: location_coordinates.latitude,
        longitude: location_coordinates.longitude,
      )
    else
      preference.location_preferences.create(
        within:,
        name:,
        latitude: location_coordinates.latitude,
        longitude: location_coordinates.longitude,
      )
    end
  end

private

  def location_coordinates
    Geocoder.search(
      name,
      components: 'country:UK',
    ).first
  end

  def location
    if location_coordinates.nil?
      errors.add(:base, :invalid_location)
    end
  end
end
