module DataMigrations
  class DropRestructuredImmigrationStatusFeatureFlag
    TIMESTAMP = 20220315105856
    MANUAL_RUN = false

    def change
      Feature.where(name: :restructured_immigration_status).first&.destroy
    end
  end
end
