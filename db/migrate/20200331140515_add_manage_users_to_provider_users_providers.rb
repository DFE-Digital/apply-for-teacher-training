class AddManageUsersToProviderUsersProviders < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_users_providers, :manage_users, :boolean, default: false, null: false
  end
end
