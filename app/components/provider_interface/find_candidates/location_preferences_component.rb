class ProviderInterface::FindCandidates::LocationPreferencesComponent < ViewComponent::Base
  def initialize(application_form:)
    @application_form = application_form
  end

  def preferences_text
    if published_preference&.training_locations_specific? && location_preferences.present?
      t('.specific_locations')
    else
      t('.will_train_anywhere')
    end
  end

private

  def location_preferences
    @location_preferences ||= @application_form.published_location_preferences.order(:created_at).map do |location|
      t('.location', radius: location.within, location: location.name)
    end
  end

  def published_preference
    @published_preference ||= @application_form.published_preferences.last
  end
end
