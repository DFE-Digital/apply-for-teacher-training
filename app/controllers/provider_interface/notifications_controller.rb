module ProviderInterface
  class NotificationsController < ProviderInterfaceController
    def update
      provider_user_notifications_service = SaveProviderUserNotificationPreferences.new(provider_user: current_provider_user)

      if FeatureFlag.active?(:configurable_provider_notifications)
        provider_user_notifications_service.update_all_notification_preferences!(notification_preferences_params: notification_preferences_params)
      else
        provider_user_notifications_service.backfill_notification_preferences!(send_notifications: notification_params[:send_notifications])
      end

      flash[:success] = 'Email notification settings saved'
      redirect_to provider_interface_notifications_path
    end

  private

    def notification_params
      return ActionController::Parameters.new unless params.key?(:provider_user)

      params.require(:provider_user).permit(:send_notifications)
    end

    def notification_preferences_params
      return ActionController::Parameters.new unless params.key?(:provider_user_notification_preferences)

      params.require(:provider_user_notification_preferences)
        .permit(ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES)
    end
  end
end
