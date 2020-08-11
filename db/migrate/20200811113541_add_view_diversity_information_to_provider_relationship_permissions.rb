class AddViewDiversityInformationToProviderRelationshipPermissions < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_relationship_permissions, :training_provider_can_view_diversity_information, :boolean, default: false, null: false
    add_column :provider_relationship_permissions, :ratifying_provider_can_view_diversity_information, :boolean, default: false, null: false
  end
end
