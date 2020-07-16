module ProviderInterface
  class OrganisationsController < ProviderInterfaceController
    before_action :render_403_unless_organisation_valid_for_user, only: :show

    def index
      @manageable_providers = manageable_providers
    end

    def show
      scope = ProviderRelationshipPermissions.includes(:training_provider, :ratifying_provider)

      permissions = scope.where(training_provider: manageable_providers)
        .or(scope.where(ratifying_provider: manageable_providers))

      @ratifying_permissions = permissions.select { |p| manageable_providers.include?(p.ratifying_provider) }
      @training_permissions = permissions.select { |p| manageable_providers.include?(p.training_provider) }
    end

  private

    def manageable_providers
      @_manageable_providers ||= Provider.with_permissions_visible_to(current_provider_user)
    end

    def render_403_unless_organisation_valid_for_user
      render_403 unless Provider.with_permissions_visible_to(current_provider_user).include?(provider)
    end

    def provider
      @provider ||= Provider.find(params[:id])
    end
  end
end
