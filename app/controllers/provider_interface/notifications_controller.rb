module ProviderInterface
  class NotificationsController < ProviderInterfaceController
    def update
      current_provider_user.update!(
        send_notifications: notification_params[:send_notifications],
      )

      flash[:success] = 'Email notification settings saved'
      redirect_to provider_interface_notifications_path
    end

  private

    def notification_params
      params.require(:provider_user).permit(:send_notifications)
    end
  end
end
