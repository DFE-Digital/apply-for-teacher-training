module CandidateInterface
  class OneLoginPreReleaseLoggedInBannerComponent < ViewComponent::Base
    def initialize(flash_empty:)
      @flash_empty = flash_empty
    end

    def render?
      @flash_empty &&
        FeatureFlag.active?(:one_login_pre_release_banners) &&
        FeatureFlag.inactive?(:one_login_candidate_sign_in)
    end
  end
end
