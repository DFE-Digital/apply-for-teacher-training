module CandidateInterface
  class OneLoginPostReleaseSignInBannerComponent < ViewComponent::Base
    def render?
      FeatureFlag.active?(:one_login_candidate_sign_in)
    end
  end
end
