class ProviderInterface::RejectByDefaultBannerComponent < ViewComponent::Base
  def render?
    show_reject_by_default_banner?
  end

  def show_reject_by_default_banner?
    Time.zone.now.between?(timetable.apply_deadline_at, timetable.reject_by_default_at)
  end

  def timetable
    @timetable ||= RecruitmentCycleTimetable.current_timetable
  end
end
