module RecruitmentPerformanceReportTimetable
  FIRST_CYCLE_WEEK_REPORT = 16
  LAST_CYCLE_WEEK_REPORT = 51

  def self.report_season?
    RecruitmentCycleTimetable.current_cycle_week.between?(FIRST_CYCLE_WEEK_REPORT, LAST_CYCLE_WEEK_REPORT)
  end

  def self.first_publication_date
    RecruitmentCycleTimetable.current_timetable.cycle_week_date_range(FIRST_CYCLE_WEEK_REPORT).first.to_date
  end

  # Generation and Publication date are the same (today) for now until we
  # decide otherwise

  def self.current_generation_date
    Time.zone.today
  end

  def self.current_publication_date
    Time.zone.today
  end
end
