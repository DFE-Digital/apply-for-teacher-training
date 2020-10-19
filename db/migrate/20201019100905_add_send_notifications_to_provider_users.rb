class AddSendNotificationsToProviderUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_users, :send_notifications, :boolean, null: false, default: true
  end
end
