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
    timetable_class.between_cycles?
  end

  def academic_year
    CycleTimetable.cycle_year_range(year)
  end

  def next_academic_year
    CycleTimetable.cycle_year_range(year + 1)
  end

  def apply_opens_date
    date = if Time.zone.now.before? timetable_class.apply_opens
             timetable_class.apply_opens
           else
             timetable_class.apply_reopens
           end
    date.to_fs(:govuk_date)
  end

  def year
    if Time.zone.now.before? CycleTimetable.apply_opens
      timetable_class.previous_year
    else
      timetable_class.current_year
    end
  end

  def timetable_class
    @timetable_class ||= if CycleTimetable.use_database_timetables?
                           RecruitmentCycleTimetable.current_real_timetable
                         else
                           CycleTimetable
                         end
  end
end
