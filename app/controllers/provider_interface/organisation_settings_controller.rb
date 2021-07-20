module ProviderInterface
  class OrganisationSettingsController < ProviderInterfaceController
    before_action :require_accredited_provider_setting_permissions_flag
    before_action :require_manage_users_or_manage_organisations_permission

    def show; end

  private

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
  end
end
