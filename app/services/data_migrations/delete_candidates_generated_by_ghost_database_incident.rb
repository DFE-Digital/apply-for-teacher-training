module DataMigrations
  class DeleteCandidatesGeneratedByGhostDatabaseIncident
    TIMESTAMP = 20261123095034
    MANUAL_RUN = false

    def change
      return unless Rails.env.production? || Rails.env.test?

      candidate_ids = (1..46).to_a - [36, 43, 45]
      DeleteCandidatesWorker.perform_now(candidate_ids)
    end
  end
end
