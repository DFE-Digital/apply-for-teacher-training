module DataMigrations
  class RemoveProviderReportsFeatureFlag
    TIMESTAMP = 20230602121327
    MANUAL_RUN = false

    def change
      Feature.where(name: :provider_reports).delete_all
    end
  end
end
