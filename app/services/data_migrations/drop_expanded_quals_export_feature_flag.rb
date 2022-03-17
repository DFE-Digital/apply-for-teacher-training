module DataMigrations
  class DropExpandedQualsExportFeatureFlag
    TIMESTAMP = 20220310093735
    MANUAL_RUN = false

    def change
      Feature.where(name: :expanded_quals_export).first&.destroy
    end
  end
end
