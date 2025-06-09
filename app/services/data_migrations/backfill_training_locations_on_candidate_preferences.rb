module DataMigrations
  class BackfillTrainingLocationsOnCandidatePreferences
    TIMESTAMP = 20250609145824
    MANUAL_RUN = false

    def change
      CandidatePreference
        .where(id: candidate_preferences_with_location_preferences_ids)
        .update_all(training_locations: 'specific')

      CandidatePreference
        .published
        .opt_in
        .where.not(id: candidate_preferences_with_location_preferences_ids)
        .update_all(training_locations: 'anywhere')
    end

    def candidate_preferences_with_location_preferences_ids
      @candidate_preferences_with_location_preferences_ids ||= CandidatePreference
        .published
        .opt_in
        .joins(:location_preferences)
        .pluck(:id)
    end
  end
end
