module ProviderInterface
  class NotificationsController < ProviderInterfaceController
    def update
      current_provider_user.update!(
        send_notifications: notification_params[:send_notifications],
      )
      track_notification_status_change

      flash[:success] = 'Email notification settings saved'
      redirect_to provider_interface_notifications_path
    end

  private

    def notification_params
      params.require(:provider_user).permit(:send_notifications)
    end

    def track_notification_status_change
      notification_status = current_provider_user.send_notifications ? 'on' : 'off'
      Metrics::Tracker.new(current_provider_user, "notifications.update.#{notification_status}", current_provider_user).track(:status_update)
    end
  end
end
