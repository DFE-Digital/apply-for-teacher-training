class ProviderInterface::FindCandidates::LocationPreferencesComponent < ViewComponent::Base
  def initialize(application_form:)
    @candidate = application_form.candidate
  end

  def preferences_text
    if location_preferences.empty?
      t('.will_train_anywhere')
    else
      t('.specific_locations')
    end
  end

private

  def location_preferences
    @location_preferences ||= @candidate.published_location_preferences.order(:created_at).map do |location|
      t('.location', radius: location.within, location: location.name)
    end
  end
end
