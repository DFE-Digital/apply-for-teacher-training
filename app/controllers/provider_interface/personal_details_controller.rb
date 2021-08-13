module ProviderInterface
  class PersonalDetailsController < ProviderInterfaceController
    before_action :redirect_to_profile_unless_feature_flag_on

    def show
      @dsi_profile_url = dsi_profile_url
    end

  private

    def redirect_to_profile_unless_feature_flag_on
      unless FeatureFlag.active?(:account_and_org_settings_changes)
        redirect_to provider_interface_profile_path
      end
    end

    def dsi_profile_url
      return 'https://test-profile.signin.education.gov.uk' if HostingEnvironment.qa?

      'https://profile.signin.education.gov.uk'
    end
  end
end
