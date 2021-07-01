module DataMigrations
  class BackfillSetupInterviewsPermission
    TIMESTAMP = 20210701153532
    MANUAL_RUN = true

    def change
      ActiveRecord::Base.no_touching do
        ProviderPermissions.where(make_decisions: true).update_all(set_up_interviews: true)
      end
    end
  end
end
