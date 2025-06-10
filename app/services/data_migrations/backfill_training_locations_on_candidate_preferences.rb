module DataMigrations
  class BackfillTrainingLocationsOnCandidatePreferences
    TIMESTAMP = 20250609145824
    MANUAL_RUN = false

    def change
      ActiveRecord::Base.transaction do
        candidates_preferences
          .joins(:location_preferences)
          .distinct
          .update_all(training_locations: 'specific')

        candidates_preferences
          .where.missing(:location_preferences)
          .update_all(training_locations: 'anywhere')
      end
    end

    def candidates_preferences
      @candidates_preferences ||= CandidatePreference.published.opt_in.where(training_locations: nil)
    end
  end
end
