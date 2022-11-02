module DataMigrations
  class RemoveReferencesProviderFeatureFlag
    TIMESTAMP = 20221102150928
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :new_references_flow_providers)&.destroy
    end
  end
end
