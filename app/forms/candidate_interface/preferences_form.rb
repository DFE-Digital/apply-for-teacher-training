module CandidateInterface
  class PreferencesForm
    include ActiveModel::Model
    include Rails.application.routes.url_helpers

    attr_accessor :id, :pool_status, :location_preference_ids, :preference, :dynamic_location_preferences
    attr_reader :current_candidate

    validates :pool_status, presence: true

    def initialize(current_candidate:, preference_params: {})
      @current_candidate = current_candidate
      super(preference_params)
    end

    def self.build_from_preference(preference:, current_candidate:)
      new(
        current_candidate:,
        preference_params: {
          id: preference.id,
          pool_status: preference.pool_status,
        },
      )
    end

    def dynamic_location_preferences=(value)
      @dynamic_location_preferences = value.nil? ? false : value
    end

    def save
      if id.present?
        @preference = current_candidate.preferences.find_by(id:)
        attributes = {
          pool_status:,
          dynamic_location_preferences:,
        }.compact

        ActiveRecord::Base.transaction do
          @preference.update!(attributes)
          @preference.location_preferences.draft.where(id: location_preference_ids).update!(status: :selected)
          @preference.location_preferences.selected.where.not(id: location_preference_ids).update!(status: :draft)
        end

        @preference
        true
      else
        ActiveRecord::Base.transaction do
          @preference = current_candidate.preferences.create!(pool_status:)
          set_default_location_preferences
        end

        true
      end
    end

    def redirect_path
      if preference&.opt_in?
        candidate_interface_preference_location_preferences_path(preference)
      else
        root_path
      end
    end

  private

    def set_default_location_preferences
      application_form = current_candidate.current_cycle_application_form
      sites = application_form.application_choices
        .joins(course_option: :site)
        .select('sites.postcode, sites.latitude, sites.longitude')

      attributes = sites.map do |site|
        {
          location: site.postcode,
          within: 10,
          latitude: site.latitude,
          longitude: site.longitude,
          candidate_preference_id: preference.id,
        }
      end

      attributes << {
        location: application_form.postcode,
        within: 10,
        latitude: application_form.geocode.first,
        longitude: application_form.geocode.last,
        candidate_preference_id: preference.id,
      }

      preference.location_preferences.insert_all!(attributes)
    end
  end
end
