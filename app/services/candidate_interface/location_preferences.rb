module CandidateInterface
  class LocationPreferences
    DEFAULT_RADIUS = 10
    attr_reader :preference, :application_choice

    def initialize(preference:, application_choice: nil)
      @preference = preference
      @application_choice = application_choice
    end

    def self.add_default_location_preferences(preference:)
      new(preference:).add_default_location_preferences
    end

    def add_default_location_preferences
      application_form = preference.candidate.current_cycle_application_form

      sites = application_form.application_choices.map(&:site)
      attributes = []

      attributes << add_home_address(application_form) unless application_form.international_address?

      return if application_form.application_choices.blank?

      sites.each do |site|
        attributes << {
          name: "#{site.postcode} (#{site.provider.name})",
          within: DEFAULT_RADIUS,
          latitude: site.latitude,
          longitude: site.longitude,
          candidate_preference_id: preference.id,
        }
      end

      preference.location_preferences.insert_all!(attributes)
    end

    def self.add_location_from_choice(preference:, application_choice:)
      new(preference:, application_choice:).add_location_from_choice
    end

    def add_location_from_choice
      site = application_choices.site
      return if preference.location_preferences.pluck(:name).include?(site.postcode)

      preference.location_preferences.create!(
        name: site.postcode,
        within: DEFAULT_RADIUS,
        latitude: site.latitude,
        longitude: site.longitude,
        provider_id: site.provider_id,
      )
    end

  private

    def add_home_address(application_form)
      {
        name: application_form.postcode,
        within: DEFAULT_RADIUS,
        latitude: application_form.geocode.first,
        longitude: application_form.geocode.last,
        candidate_preference_id: preference.id,
      }
    end
  end
end
