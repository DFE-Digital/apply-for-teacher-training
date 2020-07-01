class MigrateProviderRelationshipPermissionsStiRecords < ActiveRecord::Migration[6.0]
  def change
    ProviderRelationshipPermissions.where(type: 'ProviderInterface::AccreditedBodyPermissions')
      .update_all(type: 'RatifyingProviderPermissions')

    ProviderRelationshipPermissions.where(type: 'ProviderInterface::TrainingProviderPermissions')
      .update_all(type: 'TrainingProviderPermissions')
  end
end
