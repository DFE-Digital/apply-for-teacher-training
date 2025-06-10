class CandidateInterface::LocationPreferencesRequiredForm
  include ActiveModel::Model

  attr_reader :preference
  validate :location_preferences_required

  def initialize(preference:)
    @preference = preference
  end

  def location_preferences_required
    if @preference.location_preferences.blank?
      errors.add(:base, :location_preferences_blank)
    end
  end
end
