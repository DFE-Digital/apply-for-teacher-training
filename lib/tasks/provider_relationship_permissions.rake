desc 'Return all records that will be deleted when provider_relationship_permissions feature flag is active'
task verify_outdated_provider_relationship_permissions: :environment do
  records_to_be_deleted = TeacherTrainingPublicAPI::SyncProviderRelationshipPermissions.verify_outdated_provider_relationship_permissions

  records_to_be_deleted.each do |record|
    puts "Record #id '#{record.id}' will be deleted. The relationship is between #{record.training_provider.name} and #{record.ratifying_provider.name}"
  end
end
