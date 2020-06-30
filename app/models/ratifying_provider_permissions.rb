class RatifyingProviderPermissions < ProviderRelationshipPermissions
end

# Backwards compatibility for any existing db records using the old STI class name.
# This should be removed once db has been migrated.
ProviderInterface::AccreditedBodyPermissions = RatifyingProviderPermissions
