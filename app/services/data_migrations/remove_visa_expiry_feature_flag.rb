module DataMigrations
  class RemoveVisaExpiryFeatureFlag
    TIMESTAMP = 20260928115959
    MANUAL_RUN = false

    def change
      Feature.find_by(name: '2027_visa_expiry')&.destroy
    end
  end
end
