module ProviderInterface
  class NotificationsController < ProviderInterfaceController
    def update
      current_provider_user.update!(
        send_notifications: notification_params[:send_notifications],
      )

      if FeatureFlag.active?(:configurable_provider_notifications)
        current_provider_user.notification_preferences
          .update_all_preferences(notification_params[:send_notifications])
      end

      flash[:success] = 'Email notification settings saved'
      redirect_to provider_interface_notifications_path
    end

  private

    def notification_params
      params.require(:provider_user).permit(:send_notifications)
    end
  end
end
