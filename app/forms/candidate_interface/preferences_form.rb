class CandidateInterface::PreferencesForm
  include ActiveModel::Model

  attr_accessor :dynamic_location_preferences
  attr_reader :preference
  validate :location_preferences_required

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
    preference.update!(dynamic_location_preferences:) if valid?
  end

  def location_preferences_required
    if @preference.location_preferences.blank?
      errors.add(:base, :location_preferences_blank)
    end
  end
end
