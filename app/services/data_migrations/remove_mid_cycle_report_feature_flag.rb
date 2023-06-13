module DataMigrations
  class RemoveMidCycleReportFeatureFlag
    TIMESTAMP = 20230609131625
    MANUAL_RUN = false

    def change
      Feature.where(name: :mid_cycle_report).delete_all
    end
  end
end
