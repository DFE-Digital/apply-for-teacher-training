module DataMigrations
  class BackfillWeek42PerformanceReportData
    TIMESTAMP = 20240731130619
    MANUAL_RUN = false

    def change
      Publications::NationalRecruitmentPerformanceReport.where(cycle_week: 42).destroy_all
      Publications::ProviderRecruitmentPerformanceReport.where(cycle_week: 42).destroy_all

      Publications::RecruitmentPerformanceReportScheduler.new(cycle_week: 42).call
    end
  end
end
