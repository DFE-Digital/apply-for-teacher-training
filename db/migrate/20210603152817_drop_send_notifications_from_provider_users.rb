class DropSendNotificationsFromProviderUsers < ActiveRecord::Migration[6.1]
  def up
    safety_assured { remove_column :provider_users, :send_notifications }
  end

  def down
    add_column :provider_users, :send_notifications, :boolean, default: false
  end
end
