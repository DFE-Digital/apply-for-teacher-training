module DataMigrations
  class RemoveMidCycleReportsFeatureFlag
    TIMESTAMP = 20230607132325
    MANUAL_RUN = false

    def change
      Feature.where(name: :mid_cycle_reports).delete_all
    end
  end
end
