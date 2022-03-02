module DataMigrations
  class DropRegionFromPostcodeFeatureFlag
    TIMESTAMP = 20220302105929
    MANUAL_RUN = false

    def change
      Feature.where(name: :region_from_postcode).first&.destroy
    end
  end
end
