class AddChaseProviderDecisionToProviderUserNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :provider_user_notifications, :chase_provider_decision, :boolean, null: false, default: true
  end
end
