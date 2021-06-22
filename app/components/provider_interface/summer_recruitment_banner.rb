module ProviderInterface
  class SummerRecruitmentBanner < ViewComponent::Base
    def render?
      FeatureFlag.active?('summer_recruitment_banner')
    end
  end
end
