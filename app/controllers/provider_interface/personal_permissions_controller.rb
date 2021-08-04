module ProviderInterface
  class PersonalPermissionsController < ProviderInterfaceController
    before_action :redirect_to_account_unless_feature_flag_on

    def show
      @providers = current_provider_user.providers.order(:name)
    end

  private

    def redirect_to_account_unless_feature_flag_on
      unless FeatureFlag.active?(:account_and_org_settings_changes)
        redirect_to provider_interface_account_path
      end
    end
  end
end
