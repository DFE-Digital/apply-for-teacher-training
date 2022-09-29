class AddReferenceReceivedToProviderUserNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_user_notifications, :reference_received, :boolean, default: true
  end
end
