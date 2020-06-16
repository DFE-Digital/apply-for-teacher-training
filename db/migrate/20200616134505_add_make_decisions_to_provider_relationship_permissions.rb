class AddMakeDecisionsToProviderRelationshipPermissions < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_relationship_permissions, :make_decisions, :boolean, default: false, null: false
  end
end
