module ProviderInterface
  class SummerRecruitmentBanner < ViewComponent::Base
    def render?
      FeatureFlag.active?('summer_recruitment_banner')
    end

  private

    def render_body?
      Time.zone.now < CycleTimetable.apply_2_deadline(RecruitmentCycle.current_year)
    end
  end
end
