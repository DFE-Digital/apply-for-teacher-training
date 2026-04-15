class AddMarketingEmailsToProviderUserNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    add_column :provider_user_notifications, :marketing_emails, :boolean, default: true, null: false
  end
end
