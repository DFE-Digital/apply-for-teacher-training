class CandidateInterface::PreferencesForm
  include ActiveModel::Model

  attr_accessor :dynamic_location_preferences
  attr_reader :preference

  validate :location_preferences_presence

  def initialize(preference:, params: {})
    @preference = preference
    super(params)
  end

  def self.build_from_preference(preference:)
    new(
      preference:,
      params: {
        dynamic_location_preferences: preference.dynamic_location_preferences,
      },
    )
  end

  def save
    return if invalid?

    preference.update!(dynamic_location_preferences:)
  end

private

  def location_preferences_presence
    if preference.location_preferences.blank?
      errors.add(:base, :location_preferences_blank)
    end
  end
end
