module SupportInterface
  class NotificationsExport
    def data_for_export
      active_provider_users = ProviderUser.includes(:providers)
      active_provider_users.flat_map { |provider_user| data_for_user(provider_user) }
    end

  private

    def data_for_user(provider_user)
      {
        text_for(:email_address) => provider_user.email_address,
        text_for(:notification_setting) => provider_user.send_notifications? ? 'Yes' : 'No',
        text_for(:notifications_for_setting, status: 'On') => metrics_data_for(provider_user, key: 'notifications.on'),
        text_for(:notifications_for_setting, status: 'Off') => metrics_data_for(provider_user, key: 'notifications.off'),
        text_for(:number_of_changes) => metrics_data_for(provider_user, event: :status_update),
        text_for(:notifications_received) => [metrics_data_for(provider_user, key: 'notifications.off'), metrics_data_for(provider_user, key: 'notifications.on')].inject(:+),
        notifications_received_for(:application_submitted) => metrics_data_for(provider_user, event: :application_submitted),
        notifications_received_for(:application_submitted_with_safeguarding_issues) => metrics_data_for(provider_user, event: :application_submitted_with_safeguarding_issues),
        notifications_received_for(:application_submitted_with_no_response) => metrics_data_for(provider_user, event: :application_with_no_response),
        notifications_received_for(:application_rejected_by_default) => metrics_data_for(provider_user, event: :application_rejected_by_default),
        notifications_received_for(:application_withdrawn) => metrics_data_for(provider_user, event: :application_withdrawn),
        notifications_received_for(:offer_accepted) => metrics_data_for(provider_user, event: :offer_accepted),
        notifications_received_for(:offer_declined) => metrics_data_for(provider_user, event: :offer_declined),
        notifications_received_for(:offer_declined_by_default) => metrics_data_for(provider_user, event: :offer_declined_by_default),
        notifications_received_for(:note_added) => metrics_data_for(provider_user, event: :note_added),
        text_for(:decision_count, status: 'On') => metrics_data_for(provider_user, key: 'notifications.on', event: :decision),
        text_for(:decision_count, status: 'Off') => metrics_data_for(provider_user, key: 'notifications.off', event: :decision),
        text_for(:avg_decision_time) => 0,
        text_for(:avg_decision_time_on) => 0,
        text_for(:avg_decision_time_off) => 0,
        text_for(:org_users_with_notifications, status: 'On') => org_users_with_notifications(provider_user, status: 'on'),
        text_for(:org_users_with_notifications, status: 'Off') => org_users_with_notifications(provider_user, status: 'off'),
        text_for(:automatic_rejections) => 0,
      }
    end

    def text_for(event, params = nil)
      I18n.t("notifications_export.#{event}", params)
    end

    def notifications_received_for(event)
      event_string = text_for(event)
      "Number of Notifications received for: #{event_string}"
    end

    def metrics_data_for(provider_user, key: nil, event: nil)
      Metrics::Data.new(provider_user).for(key, event).count
    end

    def org_users_with_notifications(provider_user, status: 'on')
      send_notifications = (status == 'on')
      provider_user.providers.map { |provider| provider.provider_users.where(send_notifications: send_notifications) }.flatten.count
    end
  end
end
