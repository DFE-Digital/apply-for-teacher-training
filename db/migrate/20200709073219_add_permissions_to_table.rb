class AddPermissionsToTable < ActiveRecord::Migration[6.0]
  def up
    remove_column :provider_relationship_permissions, :make_decisions
    remove_column :provider_relationship_permissions, :view_safeguarding_information
    remove_column :provider_relationship_permissions, :type
    add_column :provider_relationship_permissions, :training_provider_can_make_decisions, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :training_provider_can_view_safeguarding_information, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :ratifying_provider_can_make_decisions, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :ratifying_provider_can_view_safeguarding_information, :boolean, null: false, default: false
  end

  def down
    add_column :provider_relationship_permissions, :make_decisions, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :view_safeguarding_information, :boolean, null: false, default: false
    add_column :provider_relationship_permissions, :type, :string, null: false 
    remove_column :provider_relationship_permissions, :training_provider_can_make_decisions
    remove_column :provider_relationship_permissions, :training_provider_can_view_safeguarding_information
    remove_column :provider_relationship_permissions, :ratifying_provider_can_make_decisions
    remove_column :provider_relationship_permissions, :ratifying_provider_can_view_safeguarding_information
  end
end
