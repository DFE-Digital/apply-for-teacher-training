class CandidateInterface::ReopenBannerComponent < ViewComponent::Base
  attr_accessor :flash_empty, :current_timetable

  def initialize(flash_empty:, current_timetable:)
    @flash_empty = flash_empty
    @current_timetable = current_timetable
  end

  def render?
    flash_empty && show_apply_reopen_banner?
  end

private

  def show_apply_reopen_banner?
    # We show this banner between the application deadline in one cycle and apply opening in the next
    # So the current_timetable could be the one for which the deadline has passed
    # Or the one about to open.
    after_deadline? || before_applications_open?
  end

  def current_academic_year
    if in_new_cycle?
      relative_previous_timetable.academic_year_range_name
    else
      current_timetable.academic_year_range_name
    end
  end

  def next_academic_year
    if in_new_cycle?
      current_timetable.academic_year_range_name
    else
      relative_next_timetable.academic_year_range_name
    end
  end

  def apply_opens_date
    date = if in_new_cycle?
             current_timetable.apply_opens_at
           else
             relative_next_timetable.apply_opens_at
           end
    date.to_fs(:govuk_date)
  end

  def relative_next_timetable
    @relative_next_timetable ||= current_timetable.relative_next_timetable
  end

  def relative_previous_timetable
    @relative_previous_timetable ||= current_timetable.relative_previous_timetable
  end

  def after_deadline?
    Time.zone.now.after?(current_timetable.apply_deadline_at)
  end

  def before_applications_open?
    Time.zone.now.before?(current_timetable.apply_opens_at)
  end
  alias in_new_cycle? before_applications_open?
end
