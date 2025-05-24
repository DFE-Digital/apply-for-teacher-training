module Publications
  class MonthlyStatistics::Timetable
    attr_reader :recruitment_cycle_timetable

    delegate :apply_opens_at, :find_closes_at, to: :recruitment_cycle_timetable

    GAP_BETWEEN_GENERATION_AND_PUBLICATION = 1.week

    def initialize(recruitment_cycle_timetable: RecruitmentCycleTimetable.current_timetable)
      @recruitment_cycle_timetable = recruitment_cycle_timetable
    end

    def schedules
      @schedules ||= schedules_for_cycle
    end

    def unpublished_schedules
      schedules.filter do |schedule|
        schedule.publication_date.after? Time.zone.today
      end
    end

    def next_publication_date
      if unpublished_schedules.blank?
        MonthlyStatistics::Timetable.new(
          recruitment_cycle_timetable: next_recruitment_cycle_for_publishing_stats,
        ).next_publication_date
      else
        unpublished_schedules.first.publication_date
      end
    end

    def generation_today_schedule
      schedules.find do |schedule|
        schedule.generation_date == Time.zone.today
      end
    end

    def generate_today?
      generation_today_schedule.present?
    end

    def generated_schedules
      schedules.filter do |schedule|
        schedule.generation_date.before? Time.zone.today
      end
    end

  private

    def next_recruitment_cycle_for_publishing_stats
      if recruitment_cycle_timetable.current_year?
        RecruitmentCycleTimetable.next_timetable
      else
        RecruitmentCycleTimetable.current_timetable
      end
    end

    def schedules_for_cycle
      report_month = (apply_opens_at + 1.month)

      # We want at least 4 weeks of data before we generate the first report
      # If apply opens in late September, the next month is October but too early in the cycle to generate useful data
      report_month += 1.month if third_monday_of_the_month(report_month).before? apply_opens_at + 4.weeks

      schedule = Struct.new(:generation_date, :publication_date)
      [].tap do |collection|
        while report_month.before? find_closes_at
          generation_date = third_monday_of_the_month(report_month).to_date
          collection << schedule.new(
            generation_date:,
            publication_date: generation_date + GAP_BETWEEN_GENERATION_AND_PUBLICATION,
          )
          report_month += 1.month
        end
      end
    end

    def third_monday_of_the_month(month)
      first_of_month = month.change(day: 1)

      if first_of_month.monday?
        first_of_month + 2.weeks
      else
        first_of_month.next_occurring(:monday) + 2.weeks
      end
    end
  end
end
