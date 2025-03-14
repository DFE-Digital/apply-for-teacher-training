module ProviderInterface
  class NotificationsController < ProviderInterfaceController
    def show; end

    def update
      provider_user_notifications_service = SaveProviderUserNotificationPreferences.new(provider_user: current_provider_user)

      provider_user_notifications_service.update_all_notification_preferences!(notification_preferences_params:)

      flash[:success] = 'Email notification settings saved'
      redirect_to provider_interface_notifications_path
    end

  private

    def notification_preferences_params
      return ActionController::Parameters.new unless params.key?(:provider_user_notification_preferences)

      params
        .expect(provider_user_notification_preferences: ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES)
    end
  end
end
