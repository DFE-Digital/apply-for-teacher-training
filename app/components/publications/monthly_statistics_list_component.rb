module Publications
  class MonthlyStatisticsListComponent < ViewComponent::Base
    attr_accessor :recruitment_cycle_timetable

    delegate :cycle_range_name,
             :find_opens_at,
             :find_closes_at,
             to: :recruitment_cycle_timetable

    def initialize(recruitment_cycle_timetable)
      @recruitment_cycle_timetable = recruitment_cycle_timetable
    end

    def reports
      @reports ||= Publications::MonthlyStatistics::MonthlyStatisticsReport
        .published
        .where(generation_date: find_opens_at..find_closes_at)
        .order(generation_date: :desc)
    end

    def next_report
      @next_report ||= Publications::MonthlyStatistics::Timetable.new(
        recruitment_cycle_timetable:,
      ).unpublished_schedules.first
    end
  end
end
