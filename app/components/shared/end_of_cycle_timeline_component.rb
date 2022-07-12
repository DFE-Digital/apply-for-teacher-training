class EndOfCycleTimelineComponent < ViewComponent::Base
  attr_reader :timetable

  def initialize
    @timetable = CycleTimetable::CYCLE_DATES[CycleTimetable.current_year].merge(
      {
        find_reopens: CycleTimetable.find_reopens,
        apply_reopens: CycleTimetable.apply_reopens,
      },
    )
  end
end
