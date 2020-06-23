module ProviderRelationshipPermissionsHelper
  def permit_provider_make_decisions!(training_provider:, ratifying_provider:)
    FeatureFlag.activate 'enforce_provider_to_provider_permissions'

    if ratifying_provider
      ProviderInterface::TrainingProviderPermissions.find_or_create_by(
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
      ).update(make_decisions: true)

      ProviderInterface::AccreditedBodyPermissions.find_or_create_by(
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
      ).update(make_decisions: true)
    end
  end
end
