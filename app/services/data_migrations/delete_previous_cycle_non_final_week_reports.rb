module DataMigrations
  class DeletePreviousCycleNonFinalWeekReports
    TIMESTAMP = 20261106155436
    MANUAL_RUN = false

    REPORTS = [
      Publications::NationalRecruitmentPerformanceReport,
      Publications::RegionalRecruitmentPerformanceReport,
      Publications::RegionalEdiReport,
      Publications::ProviderRecruitmentPerformanceReport,
      Publications::ProviderEdiReport,
    ].freeze

    def change
      recruitment_cycle_year = RecruitmentCycleTimetable.previous_year
      final_week = Publications::NationalRecruitmentPerformanceReport
        .last_in_year(recruitment_cycle_year)
        &.cycle_week
      return if final_week.nil?

      REPORTS.each do |report|
        report.where(recruitment_cycle_year:).where.not(cycle_week: final_week).delete_all
      end
    end
  end
end
