class EndOfCycleTimelineComponent < ViewComponent::Base
  attr_reader :cycle_timetable
  Timetable = Struct.new(:name, :date, :description, keyword_init: true)
  ALTERNATIVE_NAMES = {
    reject_by_default: 'Applications are automatically rejected',
  }.freeze

  def initialize
    @cycle_timetable = CYCLE_DATES[CycleTimetable.current_year].merge(
      {
        find_reopens: CycleTimetable.find_reopens,
        apply_reopens: CycleTimetable.apply_reopens,
      },
    )
  end

  def timetable
    @cycle_timetable.flat_map do |key, value|
      next if key == :holidays

      Timetable.new(
        name: ALTERNATIVE_NAMES[key] || key.to_s.humanize,
        date: value.to_fs(:govuk_date_and_time),
        description: I18n.t("cycle_timeline.#{key}"),
      )
    end.compact
  end
end
