class AddSetupAtTimestampToProviderRelationshipPermissions < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_relationship_permissions, :setup_at, :datetime
  end
end
