module DataMigrations
  class DropImmigrationEntryDateFeatureFlag
    TIMESTAMP = 20220315111535
    MANUAL_RUN = false

    def change
      Feature.where(name: :immigration_entry_date).first&.destroy
    end
  end
end
