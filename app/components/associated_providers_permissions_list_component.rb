class AssociatedProvidersPermissionsListComponent < ViewComponent::Base
  attr_reader :permission_name

  def initialize(provider:, permission_name:)
    @provider = provider
    @permission_name = permission_name
  end

  def training_providers_that_can(permission_name)
    @provider.ratifying_provider_permissions.map { |permission_relationship|
      permission_relationship.training_provider if permission_relationship.send("training_provider_can_#{permission_name}?")
    }.compact
  end

  def training_providers_that_cannot(permission_name)
    @provider.ratifying_provider_permissions.map(&:training_provider) - training_providers_that_can(permission_name)
  end

  def ratifying_providers_that_can(permission_name)
    @provider.training_provider_permissions.map { |permission_relationship|
      permission_relationship.ratifying_provider if permission_relationship.send("ratifying_provider_can_#{permission_name}?")
    }.compact
  end

  def ratifying_providers_that_cannot(permission_name)
    @provider.training_provider_permissions.map(&:ratifying_provider) - ratifying_providers_that_can(permission_name)
  end
end
