class NotificationsList
  NOTIFICATION_PREFERENCE_NAMES_FOR_EVENTS = {
    application_received: %i[application_submitted],
    application_withdrawn: %i[application_withdrawn],
    application_rejected_by_default: %i[application_rejected_by_default],
    offer_accepted: %i[offer_accepted unconditional_offer_accepted],
    offer_declined: %i[declined declined_by_default],
    chase_provider_decision: %i[chase_provider_decision],
  }.freeze

  OLD_NOTIFICATION_PREFERENCE_NAMES_FOR_EVENTS = {
    application_received: %i[application_submitted chase_provider_decision],
    application_withdrawn: %i[application_withdrawn],
    application_rejected_by_default: %i[application_rejected_by_default],
    offer_accepted: %i[offer_accepted unconditional_offer_accepted],
    offer_declined: %i[declined declined_by_default],
  }.freeze

  def self.for(application_choice, include_ratifying_provider: false, event: nil)
    notification_name = feature_flag_preference_names.select { |k, v| k if event.in? v }.keys.first
    raise 'Undefined type of notification event' unless ProviderUserNotificationPreferences.notification_preference_exists?(notification_name)

    return application_choice.provider.provider_users.joins(:notification_preferences).where("#{notification_name} IS true") if application_choice.accredited_provider.nil? || !include_ratifying_provider

    application_choice.provider.provider_users.or(application_choice.accredited_provider.provider_users)
      .joins(:notification_preferences).where("#{notification_name} IS true").distinct
  end

  def self.feature_flag_preference_names
    if FeatureFlag.active?(:make_decision_reminder_notification_setting)
      NOTIFICATION_PREFERENCE_NAMES_FOR_EVENTS
    else
      OLD_NOTIFICATION_PREFERENCE_NAMES_FOR_EVENTS
    end
  end
end
