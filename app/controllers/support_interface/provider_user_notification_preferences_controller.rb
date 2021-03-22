module SupportInterface
  class ProviderUserNotificationPreferencesController < SupportInterfaceController

    def toggle_notifications
      provider_user = ProviderUser.find(params[:provider_user_id])
      provider_user.update!(send_notifications: !provider_user.send_notifications)

      if FeatureFlag.active?(:configurable_provider_notifications)
        provider_user.notification_preferences
          .update_all_preferences(provider_user.send_notifications)
      end

      flash[:success] = 'Provider user updated'
      redirect_to support_interface_provider_user_path(provider_user)
    end

    def update_notifications
      render_404 unless FeatureFlag.active?(:configurable_provider_notifications)

      provider_user = ProviderUser.find(params[:provider_user_id])
      notification_preferences = provider_user.notification_preferences

      if notification_preferences.update!(notification_preferences_params)
        flash[:success] = 'Provider user notifications updated'
        redirect_to support_interface_provider_user_path(provider_user)
      end
    end

  private

    def notification_preferences_params
      return ActionController::Parameters.new unless params.key?(:provider_user_notification_preferences)

      params.require(:provider_user_notification_preferences)
        .permit(ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES)
    end
  end
end
