module DataMigrations
  class BackfillChaseProviderDecisionSetting
    TIMESTAMP = 20220225092605
    MANUAL_RUN = false

    def change
      ProviderUserNotificationPreferences.where(application_received: false).find_each do |preference|
        preference.update!(chase_provider_decision: false)
      end
    end
  end
end
