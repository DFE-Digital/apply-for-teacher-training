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

      ActiveRecord::Base.transaction do
        unless application_form.international_address?
          preference.location_preferences.create!(
            name: application_form.postcode,
            within: DEFAULT_RADIUS,
            latitude: application_form.geocode.first,
            longitude: application_form.geocode.last,
          )
        end

        sites.each do |site|
          preference.location_preferences.create!(
            name: site.postcode,
            within: DEFAULT_RADIUS,
            latitude: site.latitude,
            longitude: site.longitude,
            provider_id: site.provider_id,
          )
        end
      end
    end

    def self.add_dynamic_location(preference:, application_choice:)
      new(preference:, application_choice:).add_dynamic_location
    end

    def add_dynamic_location
      return if preference.nil? || preference.opt_out?

      site = application_choice.site
      return if preference.location_preferences.pluck(:name).include?(site.postcode)

      preference.location_preferences.create!(
        name: site.postcode,
        within: DEFAULT_RADIUS,
        latitude: site.latitude,
        longitude: site.longitude,
        provider_id: site.provider_id,
      )
    end
  end
end
