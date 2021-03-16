class SaveProviderUserNotificationPreferences
  attr_reader :notification_params, :provider_user

  def initialize(provider_user:, notification_params: {})
    @provider_user = provider_user
    @notification_params = notification_params
  end

  def call!
    return false unless notification_params.key?(:send_notifications)

    provider_user.update!(send_notifications: notification_params[:send_notifications])
    provider_user_notification_preferences.update_all_preferences(notification_params[:send_notifications])
  end

private

  def provider_user_notification_preferences
    provider_user.notification_preferences ||
      ProviderUserNotificationPreferences.create!(provider_user: provider_user)
  end
end
