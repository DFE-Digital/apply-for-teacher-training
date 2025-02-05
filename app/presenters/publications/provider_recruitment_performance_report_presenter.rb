module Publications
  class ProviderRecruitmentPerformanceReportPresenter < SimpleDelegator
    delegate :cycle_range_name,
             :relative_next_timetable,
             :relative_previous_timetable,
             :cycle_week_date_range,
             :find_opens_at,
             :find_closes_at, to: :recruitment_cycle_timetable

    def next_reporting_start_date
      relative_next_timetable
      .cycle_week_date_range(RecruitmentPerformanceReportTimetable::FIRST_CYCLE_WEEK_REPORT)
      .first
      .to_fs(:govuk_date)
    end

    def next_cycle_range_name
      relative_next_timetable.cycle_range_name
    end

    def report_starting_date
      cycle_week_date_range(RecruitmentPerformanceReportTimetable::FIRST_CYCLE_WEEK_REPORT)
        .first
        .to_fs(:govuk_date)
    end

    def report_show_data_from_date
      find_opens_at.to_date.to_fs(:govuk_date)
    end

    def report_show_data_to_date
      find_closes_at.to_fs(:govuk_date)
    end

    def last_cycle_start_date
      relative_previous_timetable
        .find_opens_at
        .to_fs(:govuk_date)
    end

    def this_cycle_start_date
      find_opens_at.to_fs(:govuk_date)
    end

    def show_changes_section?
      recruitment_cycle_year == 2024
    end
  end
end
