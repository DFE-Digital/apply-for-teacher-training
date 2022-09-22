module DataMigrations
  class RemoveLockExternalReportFeatureFlag
    TIMESTAMP = 20220922143134
    MANUAL_RUN = false

    def change
      Feature.where(name: 'lock_external_report_to_december_2021').destroy_all
    end
  end
end
