module DataMigrations
  class RemoveProviderActivityLogFeatureFlag
    TIMESTAMP = 20240115113043
    MANUAL_RUN = false

    def change
      Feature.where(name: :provider_activity_log).first&.destroy
    end
  end
end
