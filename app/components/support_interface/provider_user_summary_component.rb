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
        { key: 'Account created at', value: provider_user.created_at.to_s(:govuk_date_and_time) },
        { key: 'Last sign in at', value: provider_user.last_signed_in_at&.to_s(:govuk_date_and_time) || 'Not signed in yet' },
        {
          key: 'Email notifications',
          value: email_notifications_value,
          action: 'notifications',
          change_path: edit_support_interface_provider_user_path(provider_user, anchor: 'update-email-notifications'),
        },
        {
          key: 'Permissions',
          value: render(SupportInterface::ProviderUserPermissionsComponent.new(provider_user: provider_user)),
          action: 'permissions',
          change_path: edit_support_interface_provider_user_path(provider_user),
        },
      ]
    end

  private

    def email_notifications_value
      FeatureFlag.active?(:configurable_provider_notifications) ? render(SummaryCardComponent.new(rows: notification_preferences_rows, border: false)) : boolean_to_word(provider_user.send_notifications?)
    end

    def notification_preferences_rows
      rows = ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.map do |type|
        [t("provider_user_notification_preferences.#{type}.legend"), provider_user.notification_preferences.send(type) ? 'On' : 'Off']
      end
      rows.to_h
    end
  end
end
