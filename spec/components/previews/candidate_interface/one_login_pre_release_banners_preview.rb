module CandidateInterface
  class OneLoginPreReleaseBannersPreview < ViewComponent::Preview
    def one_login_pre_release_logged_in_banner_component
      render(CandidateInterface::OneLoginPreReleaseLoggedInBannerComponent.new(flash_empty: true))
    end

    def one_login_pre_release_sign_in_banner_component
      render(CandidateInterface::OneLoginPreReleaseSignInBannerComponent.new)
    end
  end
end
