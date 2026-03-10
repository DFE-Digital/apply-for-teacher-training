module DataMigrations
  class BackfillRecruitmentReportFilters
    TIMESTAMP = 20260309160158
    MANUAL_RUN = false

    def change
      RegionalReportFilter.update_all(recruitment_cycle_year: 2026)
    end
  end
end
