class RemoveProviderRelationshipPermissionsRecords < ActiveRecord::Migration[6.0]
  def change
    ProviderRelationshipPermissions.delete_all
  end
end
