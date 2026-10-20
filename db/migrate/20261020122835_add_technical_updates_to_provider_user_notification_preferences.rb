class AddTechnicalUpdatesToProviderUserNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    add_column :provider_user_notifications, :technical_updates, :boolean, default: true, null: false
  end
end
