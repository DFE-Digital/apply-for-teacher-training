module ProviderInterface
  class OrganisationsController < ProviderInterfaceController
    before_action :render_403_unless_organisation_valid_for_user, only: :show

    def index; end

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
      render_403 unless current_provider_user.providers.include?(provider)
    end

    def provider
      @provider ||= Provider.find(params[:id])
    end
  end
end
