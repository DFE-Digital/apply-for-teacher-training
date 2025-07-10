module CandidateInterface
  class TrainingLocationsForm
    include ActiveModel::Model
    include Rails.application.routes.url_helpers

    LOCATION_OPTIONS = %w[anywhere specific].freeze

    attr_accessor :preference, :training_locations
    validates :training_locations, inclusion: { in: LOCATION_OPTIONS }

    def self.build_from_preference(preference)
      new({ training_locations: preference.training_locations, preference: })
    end

    def save!
      ActiveRecord::Base.transaction do
        preference.update!(training_locations:)
        if preference.reload.training_locations_specific? && preference.location_preferences.empty?
          LocationPreferences.add_default_location_preferences(preference:)
        end
      end
    end

    def next_step_path(return_to: nil)
      if return_to == 'review' && preference.training_locations_anywhere?
        return candidate_interface_draft_preference_path(preference)
      end

      if preference.applied_only_to_salaried_courses? && preference.training_locations_anywhere?
        new_candidate_interface_draft_preference_funding_type_preference_path(preference)
      elsif preference.training_locations_anywhere?
        candidate_interface_draft_preference_path(preference)
      elsif preference.training_locations_specific?
        candidate_interface_draft_preference_location_preferences_path(preference)
      end
    end
  end
end
