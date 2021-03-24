module SupportInterface
  class ProviderUserNotificationPreferencesController < SupportInterfaceController
    def toggle_notifications
      provider_user_notifications_service.backfill_notification_preferences!(send_notifications: !provider_user.send_notifications)

      flash[:success] = 'Provider user updated'
      redirect_to support_interface_provider_user_path(provider_user)
    end

    def update_notifications
      render_404 unless FeatureFlag.active?(:configurable_provider_notifications)

      provider_user_notifications_service.update_all_notification_preferences!(notification_preferences_params: notification_preferences_params)

      flash[:success] = 'Provider user notifications updated'
      redirect_to support_interface_provider_user_path(provider_user)
    end

  private

    def provider_user_notifications_service
      SaveProviderUserNotificationPreferences.new(provider_user: provider_user)
    end

    def provider_user
      @provider_user ||= ProviderUser.find(params[:provider_user_id])
    end

    def notification_preferences_params
      return ActionController::Parameters.new unless params.key?(:provider_user_notification_preferences)

      params.require(:provider_user_notification_preferences)
        .permit(ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES)
    end
  end
end
