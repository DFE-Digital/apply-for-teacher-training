module DataMigrations
  class AddRecruitmentCycleYearToPerformanceReports
    TIMESTAMP = 20250203095305
    MANUAL_RUN = false

    def change
      start_of_2025_cycle = RecruitmentCycleTimetable.find_by(recruitment_cycle_year: 2025).find_opens_at
      Publications::NationalRecruitmentPerformanceReport
        .where('created_at < ?', start_of_2025_cycle)
        .update_all(recruitment_cycle_year: 2024)
      Publications::ProviderRecruitmentPerformanceReport
        .where('created_at < ?', start_of_2025_cycle)
        .update_all(recruitment_cycle_year: 2024)
    end
  end
end
