module SupportInterface
  class NotificationsExport
    LABELS = %i[
      provider_user_id notification_application_received notification_application_withdrawn notification_application_rbd
      notification_offer_accepted notification_offer_declined permissions_make_decisions provider_code
    ].freeze

    def data_for_export
      ProviderUserNotificationPreferences
        .joins('LEFT JOIN provider_users_providers ON provider_users_providers.provider_user_id = provider_user_notifications.provider_user_id')
        .joins('LEFT JOIN providers ON provider_users_providers.provider_id = providers.id')
        .order('provider_users_providers.provider_user_id, providers.code')
        .pluck(
          'provider_users_providers.provider_user_id',
          'provider_user_notifications.application_received',
          'provider_user_notifications.application_withdrawn',
          'provider_user_notifications.application_rejected_by_default',
          'provider_user_notifications.offer_accepted',
          'provider_user_notifications.offer_declined',
          'provider_users_providers.make_decisions',
          'providers.code',
        )
        .map { |row| LABELS.zip(row).to_h }
    end
  end
end
