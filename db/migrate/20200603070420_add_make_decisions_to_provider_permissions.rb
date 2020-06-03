class AddMakeDecisionsToProviderPermissions < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_users_providers, :make_decisions, :boolean, default: false, null: false
  end
end
