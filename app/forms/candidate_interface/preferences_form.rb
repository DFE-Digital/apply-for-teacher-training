class CandidateInterface::PreferencesForm
  include ActiveModel::Model

  attr_accessor :dynamic_location_preferences
  attr_reader :preference

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
    preference.update!(dynamic_location_preferences:)
  end
end
