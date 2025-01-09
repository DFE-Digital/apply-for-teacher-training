module DataMigrations
  class RemoveNewWithdrawalReasonsFeatureFlag
    TIMESTAMP = 20250109170301
    MANUAL_RUN = false

    def change
      Feature.where(name: :new_candidate_withdrawal_reasons).delete_all
    end
  end
end
