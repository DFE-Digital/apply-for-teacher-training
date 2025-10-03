module DataMigrations
  class RemoveCandidatePreferencesFeatureFlag
    TIMESTAMP = 20251003133827
    MANUAL_RUN = false

    def change
      Feature.where(name: :candidate_preferences)&.delete_all
    end
  end
end
