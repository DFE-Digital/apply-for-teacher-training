module DataMigrations
  class BackfillCandidateAPIUpdatedAt
    TIMESTAMP = 20210615140317
    MANUAL_RUN = false

    def change
      Candidate
        .where('candidate_api_updated_at IS NULL')
        .each { |candidate| candidate.update!(candidate_api_updated_at: candidate.created_at) }
    end
  end
end
