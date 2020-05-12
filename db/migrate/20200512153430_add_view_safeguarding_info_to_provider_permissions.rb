class AddViewSafeguardingInfoToProviderPermissions < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_users_providers, :view_safeguarding_information, :boolean, default: false, null: false
  end
end
