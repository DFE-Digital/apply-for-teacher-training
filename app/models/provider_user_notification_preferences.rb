class ProviderUserNotificationPreferences < ActiveRecord::Base
  belongs_to :provider_user

  self.table_name = :provider_user_notifications
end
