module DataMigrations
  class OneLoginReset
    TIMESTAMP = 20261105142540
    MANUAL_RUN = false

    def change
      Candidate.update_all(account_recovery_status: :not_started)
      OneLoginAuth.delete_all
    end
  end
end
