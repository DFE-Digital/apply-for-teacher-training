module DataMigrations
  class RemoveWithdrawAtCandidatesRequestFeatureFlag
    TIMESTAMP = 20240115131853
    MANUAL_RUN = false

    def change
      Feature.where(name: :withdraw_at_candidates_request).first&.destroy
    end
  end
end
