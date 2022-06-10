module ProviderInterface
  class SummerRecruitmentBanner < ViewComponent::Base
    def render?
      CycleTimetable.show_summer_recruitment_banner?
    end

    def end_date
      I18n.l(CycleTimetable.reject_by_default, format: '%d %B')
    end
  end
end
