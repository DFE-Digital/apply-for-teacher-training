module ProviderInterface
  class OrganisationsController < ProviderInterfaceController
    before_action :render_403_unless_organisation_valid_for_user, only: :show

    def index
      @manageable_providers = manageable_providers
    end

    def show; end

    def settings
      redirect_to action: :index
    end

  private

    def manageable_providers
      @_manageable_providers ||= current_provider_user.authorisation.providers_that_actor_can_manage_organisations_for(with_set_up_permissions: true)
    end

    def render_403_unless_organisation_valid_for_user
      render_403 unless manageable_providers.include?(provider)
    end

    def provider
      @provider ||= Provider.find(params[:id])
    end
  end
end
