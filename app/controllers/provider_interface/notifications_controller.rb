module ProviderInterface
  class NotificationsController < ProviderInterfaceController
    def update
      if FeatureFlag.active?(:configurable_provider_notifications)
        notification_preferences = current_provider_user.notification_preferences
        notification_preferences.assign_attributes(notification_preferences_params)

        notification_preferences.save! if notification_preferences.valid?
      else
        current_provider_user.update!(
          send_notifications: notification_params[:send_notifications],
        )
        current_provider_user.notification_preferences
          .update_all_preferences(notification_params[:send_notifications])
      end

      flash[:success] = 'Email notification settings saved'
      redirect_to provider_interface_notifications_path
    end

  private

    def notification_params
      return {} unless params.key?(:provider_user)

      params.require(:provider_user).permit(:send_notifications)
    end

    def notification_preferences_params
      return {} unless params.key?(:provider_user_notification_preferences)

      params.require(:provider_user_notification_preferences)
        .permit(ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES)
    end
  end
end
