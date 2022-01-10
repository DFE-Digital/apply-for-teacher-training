module DataMigrations
  class BackfillCandidatesSubmissionBlocked
    TIMESTAMP = 20211224095546
    MANUAL_RUN = false

    def change
      FraudMatch.where(blocked: true).find_each do |fraud_match|
        fraud_match.candidates.each do |candidate|
          candidate.update(submission_blocked: true)
        end
      end
    end
  end
end
