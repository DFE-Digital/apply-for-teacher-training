module DataMigrations
  class FixupCandidatesSubmissionBlocked
    TIMESTAMP = 20220125163203
    MANUAL_RUN = false

    def change
      DuplicateMatch.all.each do |fraud_match|
        fraud_match.candidates.each do |candidate|
          candidate.update(submission_blocked: false) unless fraud_match.blocked?
        end
      end
    end
  end
end
