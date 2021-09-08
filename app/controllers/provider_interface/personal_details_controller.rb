module ProviderInterface
  class PersonalDetailsController < ProviderInterfaceController
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
