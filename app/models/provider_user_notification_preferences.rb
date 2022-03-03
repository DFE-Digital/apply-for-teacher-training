class ProviderUserNotificationPreferences < ApplicationRecord
  belongs_to :provider_user

  audited associated_with: :provider_user, on: [:update]

  self.table_name = :provider_user_notifications

  NOTIFICATION_PREFERENCES = %i[
    application_received
    application_withdrawn
    chase_provider_decision
    application_rejected_by_default
    offer_accepted
    offer_declined
  ].freeze

  OLD_NOTIFICATION_PREFERENCES = %i[
    application_received
    application_withdrawn
    application_rejected_by_default
    offer_accepted
    offer_declined
  ].freeze

  def update_all_preferences(value)
    self.class.notification_preferences.each { |notification| assign_attributes(notification => value) }

    save!
  end

  def self.notification_preferences
    if FeatureFlag.active?(:make_decision_reminder_notification_setting)
      NOTIFICATION_PREFERENCES
    else
      OLD_NOTIFICATION_PREFERENCES
    end
  end

  def self.notification_preference_exists?(notification_name)
    notification_preferences.include? notification_name
  end
end
