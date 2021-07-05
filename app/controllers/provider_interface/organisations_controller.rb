module ProviderInterface
  class OrganisationsController < ProviderInterfaceController
    before_action :render_403_unless_organisation_valid_for_user, only: :show
    before_action :require_accredited_provider_setting_permissions_flag, only: :settings
    before_action :require_manage_users_or_manage_organisations_permission, only: :settings

    def index
      @manageable_providers = manageable_providers
    end

    def show; end

    def settings; end

  private

    def manageable_providers
      @_manageable_providers ||= current_provider_user.authorisation.providers_that_actor_can_manage_organisations_for(with_set_up_permissions: true)
    end

    def render_403_unless_organisation_valid_for_user
      render_403 unless manageable_providers.include?(provider)
    end

    def require_accredited_provider_setting_permissions_flag
      unless FeatureFlag.active?(:accredited_provider_setting_permissions)
        redirect_to(provider_interface_account_path)
      end
    end

    def require_manage_users_or_manage_organisations_permission
      unless current_provider_user.authorisation.can_manage_users_or_organisations_for_at_least_one_setup_provider?
        redirect_to(provider_interface_account_path)
      end
    end

    def provider
      @provider ||= Provider.find(params[:id])
    end
  end
end
