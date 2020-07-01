class TrainingProviderPermissions < ProviderRelationshipPermissions
end

# Backwards compatibility for any existing db records using the old STI class name.
# This can be removed once records are migrated.
ProviderInterface::TrainingProviderPermissions = TrainingProviderPermissions
