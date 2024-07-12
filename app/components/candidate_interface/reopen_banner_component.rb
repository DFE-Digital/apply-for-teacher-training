class CandidateInterface::ReopenBannerComponent < ViewComponent::Base
  attr_accessor :phase, :flash_empty

  def initialize(flash_empty:)
    @phase = phase
    @flash_empty = flash_empty
  end

  def render?
    flash_empty && show_apply_reopen_banner?
  end

private

  def show_apply_reopen_banner?
    CycleTimetable.between_cycles?
  end

  def reopen_date
    if Time.zone.now < CycleTimetable.date(:apply_opens)
      {
        date: CycleTimetable.apply_opens.to_fs(:govuk_date),
        time: CycleTimetable.apply_opens.to_fs(:govuk_time),
      }
    else
      {
        date: CycleTimetable.apply_reopens.to_fs(:govuk_date),
        time: CycleTimetable.apply_reopens.to_fs(:govuk_time),
      }
    end
  end

  def cycle_year
    @_cycle_year ||= if Time.zone.now < CycleTimetable.apply_opens
                       CycleTimetable.current_year - 1
                     else
                       CycleTimetable.current_year
                     end
  end
end
