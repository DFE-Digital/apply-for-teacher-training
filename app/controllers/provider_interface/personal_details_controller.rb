module ProviderInterface
  class PersonalDetailsController < ProviderInterfaceController
    skip_before_action :redirect_unless_user_associated_with_an_organisation

    rescue_from ProviderUserWithoutOrganisationError, with: :redirect_to_your_personal_details

    def show
      @dsi_profile_url = dsi_profile_url
    end

  private

    def dsi_profile_url
      return 'https://test-profile.signin.education.gov.uk' if HostingEnvironment.qa?

      'https://profile.signin.education.gov.uk'
    end

    def redirect_to_your_personal_details
      redirect_to provider_interface_personal_details_path
    end
  end
end
