ProviderInterface::AccreditedBodyPermissions = RatifyingProviderPermissions

class MigrateProviderRelationshipPermissionsStiRecords < ActiveRecord::Migration[6.0]
  def change
    ProviderRelationshipPermissions.where(type: 'ProviderInterface::AccreditedBodyPermissions').each do |permissions|
      existing_record = ProviderRelationshipPermissions.exists?(
        type: 'RatifyingProviderPermissions',
        ratifying_provider: permissions.ratifying_provider,
        training_provider: permissions.training_provider,
      )

      if existing_record
        permissions.delete
      else
        permissions.update(type: 'RatifyingProviderPermissions')
      end
    end

    ProviderRelationshipPermissions.where(type: 'ProviderInterface::TrainingProviderPermissions')
      .update_all(type: 'TrainingProviderPermissions')
  end
end
