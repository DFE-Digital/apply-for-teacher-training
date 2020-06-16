module ProviderInterface
  class OrganisationsController < ProviderInterfaceController
    before_action :render_403_unless_organisation_valid_for_user, only: :show

    def index
      @manageable_providers = Provider.with_permissions_visible_to(current_provider_user)
    end

    def show
      @ratifying_permissions = ProviderRelationshipPermissions
        .includes(:training_provider, :ratifying_provider)
        .where(ratifying_provider: provider)
        .group_by(&:training_provider_id)
      @training_permissions = ProviderRelationshipPermissions
        .includes(:training_provider, :ratifying_provider)
        .where(training_provider: provider)
        .group_by(&:ratifying_provider_id)
    end

  private

    def render_403_unless_organisation_valid_for_user
      render_403 unless Provider.with_permissions_visible_to(current_provider_user).include?(provider)
    end

    def provider
      @provider ||= Provider.find(params[:id])
    end
  end
end
