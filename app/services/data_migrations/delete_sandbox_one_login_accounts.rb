module DataMigrations
  class DeleteSandboxOneLoginAccounts
    TIMESTAMP = 20250604115710
    MANUAL_RUN = true

    def change
      if HostingEnvironment.sandbox_mode?
        ActiveRecord::Base.transaction do
          OneLoginAuth.delete_all
          Session.delete_all
          AccountRecoveryRequest.delete_all
          Candidate.where(
            account_recovery_status: %w[recovered dismissed],
          ).update_all(account_recovery_status: 'not_started')
        end
      end
    end
  end
end
