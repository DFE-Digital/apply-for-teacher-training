class AllowNullsForRatifyingProvidersInProviderRelationshipPermissions < ActiveRecord::Migration[6.0]
  def change
    change_column(:provider_relationship_permissions, :ratifying_provider_id, :integer, null: true)
  end
end
