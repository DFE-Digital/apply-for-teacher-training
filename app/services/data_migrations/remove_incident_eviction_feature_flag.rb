module DataMigrations
  class RemoveIncidentEvictionFeatureFlag
    TIMESTAMP = 20240318162818
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :incident_eviction)&.destroy
    end
  end
end
