class NotificationsList
  NOTIFICATION_PREFERENCE_NAMES_FOR_EVENTS = {
    application_received: %i[application_submitted],
    application_withdrawn: %i[application_withdrawn],
    application_rejected_by_default: %i[application_rejected_by_default],
    offer_accepted: %i[offer_accepted unconditional_offer_accepted],
    offer_declined: %i[declined declined_by_default],
    chase_provider_decision: %i[chase_provider_decision],
    reference_received: %i[reference_received],
  }.freeze

  def self.for(application_choice, include_ratifying_provider: false, event: nil)
    if application_choice.blank?
      Sentry.capture_message("Empty application choice when #{event}.")

      return []
    end

    notification_name = NOTIFICATION_PREFERENCE_NAMES_FOR_EVENTS.select { |k, v| k if event.in? v }.keys.first
    notification = "provider_user_notifications.#{notification_name}"

    raise 'Undefined type of notification event' unless ProviderUserNotificationPreferences.notification_preference_exists?(notification_name)

    return application_choice.provider.provider_users.joins(:notification_preferences).where(notification => true) if application_choice.accredited_provider.nil? || !include_ratifying_provider

    application_choice.provider.provider_users.or(application_choice.accredited_provider.provider_users)
      .joins(:notification_preferences).where(notification => true).distinct
  end
end
