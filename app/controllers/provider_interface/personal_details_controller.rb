module ProviderInterface
  class PersonalDetailsController < ProviderInterfaceController
    skip_before_action :redirect_unless_user_associated_with_an_organisation

    def show
      @dsi_profile_url = dsi_profile_url
    end

  private

    def dsi_profile_url
      return 'https://test-profile.signin.education.gov.uk' if HostingEnvironment.qa?

      'https://profile.signin.education.gov.uk'
    end
  end
end
