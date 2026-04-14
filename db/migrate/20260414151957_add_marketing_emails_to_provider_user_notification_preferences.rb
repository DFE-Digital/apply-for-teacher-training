class AddMarketingEmailsToProviderUserNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    add_column :provider_user_notifications, :marketing_email, :boolean, default: true, null: false
  end
end
