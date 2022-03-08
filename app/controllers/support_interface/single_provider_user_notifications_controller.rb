module SupportInterface
  class SingleProviderUserNotificationsController < ApplicationController
    def edit
      @form = SaveProviderUserNotificationPreferences.new(provider_user: provider_user_being_edited)
    end

    def update
      SaveProviderUserNotificationPreferences.new(provider_user: provider_user_being_edited)
        .update_all_notification_preferences!(notification_preferences_params: notification_preferences_params)

      flash[:success] = 'Provider user notifications updated'
      redirect_to support_interface_provider_user_path(provider_user_being_edited)
    end

  private

    def provider_user_being_edited
      @_provider_user_being_edited ||= ProviderUser.find(params[:provider_user_id])
    end

    def notification_preferences_params
      return ActionController::Parameters.new unless params.key?(:provider_user_notification_preferences)

      params.require(:provider_user_notification_preferences)
        .permit(ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES)
    end
  end
end
