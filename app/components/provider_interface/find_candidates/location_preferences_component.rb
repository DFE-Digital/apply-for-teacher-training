class ProviderInterface::FindCandidates::LocationPreferencesComponent < ApplicationComponent
  def initialize(application_form:)
    @application_form = application_form
  end

  def preferences_text
    if specific_locations?
      t('.specific_locations')
    else
      t('.will_train_anywhere')
    end
  end

  def specific_locations?
    @specific_locations ||= published_preference&.training_locations_specific? && published_location_preferences.present?
  end

private

  def published_location_preferences
    @published_location_preferences ||= @application_form.published_location_preferences.order(:created_at)
  end

  def location_preferences
    @location_preferences ||= published_location_preferences
                                    .map { |location| t('.location', radius: location.within, location: location.name) }
                                    .uniq
  end

  def published_preference
    @published_preference ||= @application_form.published_preferences.last
  end
end
