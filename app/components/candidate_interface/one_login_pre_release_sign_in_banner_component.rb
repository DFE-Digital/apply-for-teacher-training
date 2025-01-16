module CandidateInterface
  class OneLoginPreReleaseSignInBannerComponent < ViewComponent::Base
    def render?
      FeatureFlag.active?(:one_login_pre_release_banners) &&
        FeatureFlag.inactive?(:one_login_candidate_sign_in)
    end
  end
end
