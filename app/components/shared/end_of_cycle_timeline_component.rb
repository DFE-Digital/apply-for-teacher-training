class EndOfCycleTimelineComponent < ViewComponent::Base
  attr_reader :cycle_timetable
  Timetable = Struct.new(:name, :date, :description, keyword_init: true)
  ALTERNATIVE_NAMES = {
    show_summer_recruitment_banner: 'Summer recruitment period starts',
    reject_by_default: 'Applications are automatically rejected',
  }.freeze
  DESCRIPTION = {
    find_opens: 'Candidates can browse and add courses (current cycle)',
    apply_opens: 'Candidates can now submit their applications (current cycle)',
    show_deadline_banner: 'Candidates are alerted of the upcoming deadlines',
    show_summer_recruitment_banner: 'Providers are alerted that applications will be automatically rejected if they don‘t make a decision within 20 working days',
    apply_1_deadline: 'Candidates who have an Apply 1 application can no longer continue with it but can start preparing it for the new cycle',
    apply_2_deadline: 'Candidates who have an Apply 2 application can no longer continue with it but can start preparing it for the new cycle',
    reject_by_default: 'All applications are automatically rejected',
    find_closes: 'Candidates can no longer browse or add courses',
    find_reopens: 'Candidates can browse and add courses from the new cycle',
    apply_reopens: 'Candidates can now submit their applications for the new cycle',
  }.freeze

  def initialize
    @cycle_timetable = CycleTimetable::CYCLE_DATES[CycleTimetable.current_year].merge(
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
        description: DESCRIPTION[key],
      )
    end.compact
  end
end
