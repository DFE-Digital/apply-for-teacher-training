module ProviderInterface
  class NotificationsController < ProviderInterfaceController
    def update
      SaveProviderUserNotificationPreferences.new(
        provider_user: current_provider_user,
        notification_params: notification_params,
      ).call!

      flash[:success] = 'Email notification settings saved'
      redirect_to provider_interface_notifications_path
    end

  private

    def notification_params
      params.require(:provider_user).permit(:send_notifications)
    end
  end
end
