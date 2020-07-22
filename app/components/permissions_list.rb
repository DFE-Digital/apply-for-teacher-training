class PermissionsList < ViewComponent::Base
  def initialize(permission_model)
    @permission_model = permission_model
  end

  def training_providers_that_can(permission)
    permissions_as_ratifying_provider.map do |permission_relationship|
      permission_relationship.training_provider if permission_relationship.send("training_provider_can_#{permission}?")
    end
  end

  def ratifying_providers_that_can(permission)
    permissions_as_training_provider.map do |permission_relationship|
      permission_relationship.ratifying_provider if permission_relationship.send("ratifying_provider_can_#{permission}?")
    end
  end

private

  def permissions_as_ratifying_provider
    @permissions_as_ratifying_provider ||= ProviderRelationshipPermissions.where(ratifying_provider_id: @permission_model.provider.id)
  end

  def permissions_as_training_provider
    @permissions_as_training_provider ||= ProviderRelationshipPermissions.where(training_provider_id: @permission_model.provider.id)
  end
end
