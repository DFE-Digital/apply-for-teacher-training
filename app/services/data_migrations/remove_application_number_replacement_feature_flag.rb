module DataMigrations
  class RemoveApplicationNumberReplacementFeatureFlag
    TIMESTAMP = 20220420120234
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :application_number_replacement)&.destroy
    end
  end
end
