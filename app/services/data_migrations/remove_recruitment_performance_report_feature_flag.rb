module DataMigrations
  class RemoveRecruitmentPerformanceReportFeatureFlag
    TIMESTAMP = 20240611163228
    MANUAL_RUN = false

    def change
      Feature.where(name: %i[recruitment_performance_report recruitment_performance_report_generator]).delete_all
    end
  end
end
