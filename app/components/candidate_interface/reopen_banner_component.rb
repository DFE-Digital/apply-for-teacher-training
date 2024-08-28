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
    CycleTimetable.between_cycles?
  end

  def academic_year
    CycleTimetable.cycle_year_range(year)
  end

  def next_academic_year
    CycleTimetable.cycle_year_range(year + 1)
  end

  def apply_opens_date
    date = if Time.zone.now.before? CycleTimetable.apply_opens
             CycleTimetable.apply_opens
           else
             CycleTimetable.apply_reopens
           end
    date.to_fs(:govuk_date)
  end

  def year
    if Time.zone.now.before? CycleTimetable.apply_opens
      CycleTimetable.previous_year
    else
      CycleTimetable.current_year
    end
  end
end
