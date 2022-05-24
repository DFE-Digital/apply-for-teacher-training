module DataMigrations
  class RemoveDataExportsFeatureFlag
    TIMESTAMP = 20220524105501
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :data_exports)&.destroy
    end
  end
end
