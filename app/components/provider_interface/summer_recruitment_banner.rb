module ProviderInterface
  class SummerRecruitmentBanner < ViewComponent::Base
    def render?
      Time.zone.now <= CycleTimetable.apply_1_deadline && Time.zone.now >= Time.zone.local(Date.current.year, 7, 1)
    end

    def end_date
      I18n.l(CycleTimetable.reject_by_default, format: '%d %B')
    end
  end
end
