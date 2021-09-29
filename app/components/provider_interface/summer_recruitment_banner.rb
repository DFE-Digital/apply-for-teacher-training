module ProviderInterface
  class SummerRecruitmentBanner < ViewComponent::Base
    def render?
      FeatureFlag.active?('summer_recruitment_banner')
    end

  private

    def time_of_year
      after_global_rbd? ? 'after_global_rbd' : 'before_global_rbd'
    end

    def after_global_rbd?
      Time.zone.now > CycleTimetable.reject_by_default(2021)
    end
  end
end
