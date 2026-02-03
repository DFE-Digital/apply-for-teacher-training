class NotificationsList
  NOTIFICATION_PREFERENCE_NAMES_FOR_EVENTS = {
    application_received: %i[application_submitted],
    application_withdrawn: %i[application_withdrawn],
    application_rejected_by_default: %i[application_rejected_by_default],
    offer_accepted: %i[offer_accepted unconditional_offer_accepted],
    offer_declined: %i[declined declined_by_default],
    reference_received: %i[reference_received],
  }.freeze

  def self.for(application_choice, include_ratifying_provider: false, event: nil)
    if application_choice.blank?
      Sentry.capture_message("Empty application choice when #{event}.")

      return []
    end

    notification_name = NOTIFICATION_PREFERENCE_NAMES_FOR_EVENTS.select { |k, v| k if event.in? v }.keys.first

    raise 'Undefined type of notification event' unless ProviderUserNotificationPreferences.notification_preference_exists?(notification_name)

    if application_choice.accredited_provider.nil? || !include_ratifying_provider
      application_choice.provider.provider_users
        .joins(:notification_preferences)
        .where(provider_user_notifications: { notification_name.to_sym => true })
    else

      application_choice.provider.provider_users
        .or(
          application_choice.accredited_provider.provider_users,
        )
        .joins(:notification_preferences)
        .where(provider_user_notifications: { notification_name.to_sym => true })
                        .distinct
    end
  end
end
