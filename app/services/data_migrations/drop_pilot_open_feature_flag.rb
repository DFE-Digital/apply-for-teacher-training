module DataMigrations
  class DropPilotOpenFeatureFlag
    TIMESTAMP = 20220228174114
    MANUAL_RUN = false

    def change
      Feature.where(name: :pilot_open).first&.destroy
    end
  end
end
