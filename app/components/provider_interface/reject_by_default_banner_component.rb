class ProviderInterface::RejectByDefaultBannerComponent < ViewComponent::Base
  def render?
    show_reject_by_default_banner?
  end

  def reject_by_default_deadline
    {
      full_date: timetable.reject_by_default_at.to_fs(:govuk_date),
      day_and_month: timetable.reject_by_default_at.to_fs(:day_and_month),
      time: timetable.reject_by_default_at.to_fs(:govuk_time),
    }
  end

  def show_reject_by_default_banner?
    Time.zone.now.between?(timetable.apply_deadline_at, timetable.reject_by_default_at)
  end

  def timetable
    RecruitmentCycleTimetable.current_timetable
  end
end
