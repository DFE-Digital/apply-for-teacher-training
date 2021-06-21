module DataMigrations
  class BackfillCandidateAPIUpdatedAt
    TIMESTAMP = 20210615140317
    MANUAL_RUN = false

    def change
      candidates = Candidate.where(candidate_api_updated_at: nil)

      candidates.find_in_batches(batch_size: 10) do |batch|
        batch.each { |candidate| candidate.update!(candidate_api_updated_at: candidate.created_at) }
      end
    end
  end
end
