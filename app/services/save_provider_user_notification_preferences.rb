class SaveProviderUserNotificationPreferences
  attr_reader :provider_user

  def initialize(provider_user:)
    @provider_user = provider_user
  end

  def backfill_notification_preferences!(send_notifications:)
    return false if send_notifications.nil?

    update_provider_user!(send_notifications)
    provider_user_notification_preferences.update_all_preferences(send_notifications)
  end

  def update_all_notification_preferences!(notification_preferences_params: {})
    return false if notification_preferences_params.empty?

    provider_user_notification_preferences.update!(notification_preferences_params)
    update_provider_user!(send_notifications_from_notificaion_prefernces)
  end

private

  def update_provider_user!(send_notifications)
    provider_user.assign_attributes(send_notifications: send_notifications)

    provider_user.save! if provider_user.send_notifications_changed?
  end

  def provider_user_notification_preferences
    @provider_user_notification_preferences ||= provider_user.notification_preferences ||
      ProviderUserNotificationPreferences.create!(provider_user: provider_user)
  end

  def send_notifications_from_notificaion_prefernces
    values =
      provider_user_notification_preferences
        .attributes
        .with_indifferent_access
        .values_at(*ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES)
        .uniq

    return true if values.count > 1

    values.first
  end
end
