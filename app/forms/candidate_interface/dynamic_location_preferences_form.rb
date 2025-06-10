class CandidateInterface::DynamicLocationPreferencesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :dynamic_location_preferences, :boolean
  attribute :preference

  validates :dynamic_location_preferences, inclusion: { in: [true, false] }

  def self.build_from_preference(preference:)
    new(
      {
        dynamic_location_preferences: preference.dynamic_location_preferences,
        preference:,
      },
    )
  end

  def save
    preference.update!(dynamic_location_preferences:) if valid?
  end
end
