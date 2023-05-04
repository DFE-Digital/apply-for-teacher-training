module DataMigrations
  class RemoveSkeFeatureFlag
    TIMESTAMP = 20230502113523
    MANUAL_RUN = false

    def change
      Feature.where(name: %w[ske provider_ske]).delete_all
    end
  end
end
