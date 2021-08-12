module ProviderInterface
  class OrganisationSettingsController < ProviderInterfaceController
    before_action :require_manage_users_or_manage_organisations_permission

    def show
      if FeatureFlag.active?(:account_and_org_settings_changes)
        @providers = current_user.providers.order(:name)
      end
    end

  private

    def require_manage_users_or_manage_organisations_permission
      unless current_provider_user.authorisation.can_manage_users_or_organisations_for_at_least_one_setup_provider? || FeatureFlag.active?(:account_and_org_settings_changes)
        redirect_to(provider_interface_account_path)
      end
    end
  end
end
