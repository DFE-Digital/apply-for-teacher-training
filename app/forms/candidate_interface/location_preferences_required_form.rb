class CandidateInterface::LocationPreferencesRequiredForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Rails.application.routes.url_helpers

  attribute :preference
  validate :location_preferences_required

  def location_preferences_required
    if preference.location_preferences.blank?
      errors.add(:base, :location_preferences_blank)
    end
  end

  def back_path
    if preference.funding_type.present?
      new_candidate_interface_draft_preference_funding_type_preference_path(preference)
    elsif preference.training_locations_anywhere?
      new_candidate_interface_draft_preference_training_location_path(preference)
    else
      new_candidate_interface_draft_preference_dynamic_location_preference_path(preference)
    end
  end
end
