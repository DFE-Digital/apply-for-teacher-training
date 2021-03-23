module DataMigrations
  class UpsertProviderUserSendNotifications
    TIMESTAMP = 20210315142623
    MANUAL_RUN = false

    def change
      ProviderUser.find_each do |provider_user|
        preferences = ProviderUserNotificationPreferences.find_or_create_by(provider_user: provider_user)
        preferences.update_all_preferences(provider_user.send_notifications)
      end
    end
  end
end
