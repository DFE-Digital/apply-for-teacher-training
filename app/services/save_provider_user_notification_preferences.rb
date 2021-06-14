class SaveProviderUserNotificationPreferences
  attr_reader :provider_user

  def initialize(provider_user:)
    @provider_user = provider_user
  end

  def update_all_notification_preferences!(notification_preferences_params: {})
    return false if notification_preferences_params.empty?

    provider_user_notification_preferences.update!(notification_preferences_params)
  end

private

  def provider_user_notification_preferences
    @provider_user_notification_preferences ||= provider_user.notification_preferences ||
      ProviderUserNotificationPreferences.create!(provider_user: provider_user)
  end
end
