module ProviderInterface
  class ProfileController < ProviderInterfaceController
    before_action :redirect_to_personal_details_if_feature_flag_on

    def show; end

  private

    def redirect_to_personal_details_if_feature_flag_on
      if FeatureFlag.active?(:account_and_org_settings_changes)
        redirect_to provider_interface_personal_details_path
      end
    end
  end
end
