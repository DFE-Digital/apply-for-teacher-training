module DataMigrations
  class ResolveAllFraudulentDuplicateMatches
    TIMESTAMP = 20220126171018
    MANUAL_RUN = false

    def change
      FraudMatch.where(fraudulent: true).each do |fraud_match|
        fraud_match.update(resolved: true)
      end
    end
  end
end
