class AddProviderRelationshipPermissions < ActiveRecord::Migration[6.0]
  def change
    create_table :provider_relationship_permissions do |t|
      t.string :type, null: false
      t.integer :training_provider_id, null: false
      t.integer :ratifying_provider_id, null: false

      t.boolean :view_safeguarding_information, default: false, null: false

      t.timestamps
    end

    add_foreign_key :provider_relationship_permissions, :providers, column: :training_provider_id
    add_foreign_key :provider_relationship_permissions, :providers, column: :ratifying_provider_id

    add_index(
      :provider_relationship_permissions,
      %i[type training_provider_id ratifying_provider_id],
      name: 'index_provider_relationship_permissions_provider_ids_and_type',
      unique: true,
    )
  end
end
