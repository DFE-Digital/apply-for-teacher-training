class AddAPITokenManagementToProviderUserPermissions < ActiveRecord::Migration[8.0]
  def change
    add_column :provider_users_providers, :manage_api_tokens, :boolean, default: false, null: false
  end
end
