module DataMigrations
  class RemoveExportApplicationDataFeatureFlag
    TIMESTAMP = 20220613105031
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :export_application_data)&.destroy
    end
  end
end
