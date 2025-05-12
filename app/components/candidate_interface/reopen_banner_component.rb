class CandidateInterface::ReopenBannerComponent < ViewComponent::Base
  attr_accessor :flash_empty

  def initialize(flash_empty:)
    @flash_empty = flash_empty
  end

  def render?
    flash_empty && show_apply_reopen_banner?
  end

private

  def show_apply_reopen_banner?
    current_timetable.between_cycles?
  end

  def academic_year
    current_timetable.previously_closed_academic_year_range
  end

  def next_academic_year
    current_timetable.next_available_academic_year_range
  end

  def apply_opens_date
    current_timetable.apply_reopens_at.to_fs(:govuk_date)
  end

  def current_timetable
    @current_timetable ||= RecruitmentCycleTimetable.current_timetable
  end
end
