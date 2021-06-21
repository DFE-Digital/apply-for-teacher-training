module SupportInterface
  class ProviderUserSummaryComponent < SummaryListComponent
    include ViewHelper

    attr_reader :provider_user

    def initialize(provider_user)
      @provider_user = provider_user
    end

    def rows
      [
        { key: 'First name', value: provider_user.first_name },
        { key: 'Last name', value: provider_user.last_name },
        { key: 'Email address', value: provider_user.email_address },
        { key: 'DfE Sign-in UID', value: provider_user.dfe_sign_in_uid },
        {
          key: 'Email notifications',
          value: email_notifications_value,
          action: 'notifications',
          change_path: change_path,
        },
        { key: 'Account created at', value: provider_user.created_at.to_s(:govuk_date_and_time) },
        { key: 'Last sign in at', value: provider_user.last_signed_in_at&.to_s(:govuk_date_and_time) || 'Not signed in yet' },
      ]
    end

  private

    def change_path
      if FeatureFlag.active?(:new_provider_user_flow)
        support_interface_edit_permissions_path(provider_user)
      else
        edit_support_interface_provider_user_path(provider_user, anchor: 'update-email-notifications')
      end
    end

    def email_notifications_value
      render(SupportInterface::NotificationPreferencesComponent.new(rows: notification_preferences_rows))
    end

    def notification_preferences_rows
      ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.map do |type|
        { preference: t("provider_user_notification_preferences.#{type}.legend"), active: provider_user.notification_preferences.send(type) ? 'Yes' : 'No' }
      end
    end
  end
end
