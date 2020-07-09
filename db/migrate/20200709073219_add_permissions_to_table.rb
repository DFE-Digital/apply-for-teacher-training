class AddPermissionsToTable < ActiveRecord::Migration[6.0]
  def up
    remove_column :provider_relationship_permissions, :make_decisions
    remove_column :provider_relationship_permissions, :view_safeguarding_information
    remove_column :provider_relationship_permissions, :type
    add_column :provider_relationship_permissions, :training_provider_can_make_decisions, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :training_provider_can_view_safeguarding_information, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :ratifying_provider_can_make_decisions, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :ratifying_provider_can_view_safeguarding_information, :boolean, null: false, default: false

    ActiveRecord::Base.connection.execute('TRUNCATE provider_relationship_permissions')

    add_index :provider_relationship_permissions, %i[training_provider_id ratifying_provider_id], unique: true, name: :index_relationships_on_training_and_ratifying_provider_ids
  end

  def down
    add_column :provider_relationship_permissions, :make_decisions, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :view_safeguarding_information, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :type, :string, null: false
    remove_column :provider_relationship_permissions, :training_provider_can_make_decisions
    remove_column :provider_relationship_permissions, :training_provider_can_view_safeguarding_information
    remove_column :provider_relationship_permissions, :ratifying_provider_can_make_decisions
    remove_column :provider_relationship_permissions, :ratifying_provider_can_view_safeguarding_information

    remove_index :provider_relationship_permissions, %i[training_provider_id ratifying_provider_id], unique: true, name: :index_relationships_on_training_and_ratifying_provider_ids
  end
end
