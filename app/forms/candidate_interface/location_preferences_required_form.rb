class CandidateInterface::LocationPreferencesRequiredForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :preference
  validate :location_preferences_required

  def location_preferences_required
    if preference.location_preferences.blank?
      errors.add(:base, :location_preferences_blank)
    end
  end
end
