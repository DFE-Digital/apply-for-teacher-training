module RecruitmentPerformanceReportTimetable
  FIRST_CYCLE_WEEK_REPORT = 27
  LAST_CYCLE_WEEK_REPORT = 51

  def self.report_season?
    CycleTimetable.current_cycle_week.between?(FIRST_CYCLE_WEEK_REPORT, LAST_CYCLE_WEEK_REPORT) && FeatureFlag.active?(:recruitment_performance_report_generator)
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
