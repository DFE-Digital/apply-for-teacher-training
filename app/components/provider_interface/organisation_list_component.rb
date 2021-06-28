module ProviderInterface
  class OrganisationListComponent < ViewComponent::Base
    attr_accessor :training_permissions, :ratifying_permissions, :current_provider_user

    def initialize(provider:,  current_provider_user:)
      @current_provider_user = current_provider_user
      @training_permissions = ProviderRelationshipPermissions.where(training_provider: provider)
        .or(ProviderRelationshipPermissions.where(training_provider: all_manageable_providers, ratifying_provider: provider))
        .where.not(setup_at: nil)
        .includes(:training_provider)
        .sort_by { |permissions| permissions.ratifying_provider.name }
      @ratifying_permissions = ProviderRelationshipPermissions.where(ratifying_provider: provider)
        .where.not(training_provider: all_manageable_providers)
        .includes(:training_provider, :ratifying_provider)
        .sort_by { |permissions| permissions.training_provider.name }
    end

  private

    def all_manageable_providers
      current_provider_user.authorisation.providers_that_actor_can_manage_organisations_for
    end
  end
end
