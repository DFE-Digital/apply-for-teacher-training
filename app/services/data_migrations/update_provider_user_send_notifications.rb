module DataMigrations
  class UpdateProviderUserSendNotifications
    TIMESTAMP = 20210315142623
    MANUAL_RUN = false

    def change
      ProviderUserNotificationPreferences.find_each do |preferences|
        send_notifications = ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.map { |pref| preferences.send(pref) }.any?(true)

        if preferences.provider_user.send_notifications != send_notifications
          preferences.provider_user.update!(send_notifications: send_notifications)
        end
      end
    end
  end
end
