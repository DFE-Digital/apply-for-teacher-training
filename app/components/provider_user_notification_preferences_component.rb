class ProviderUserNotificationPreferencesComponent < ViewComponent::Base
  include ViewHelper
  attr_reader :notification_preferences, :form_path

  def initialize(notification_preferences, form_path:)
    @notification_preferences = notification_preferences
    @form_path = form_path
  end

  def on_off_options
    [
      OpenStruct.new(value: 'true', name: 'On'),
      OpenStruct.new(value: 'false', name: 'Off'),
    ]
  end
end
