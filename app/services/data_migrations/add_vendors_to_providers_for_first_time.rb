module DataMigrations
  class AddVendorsToProvidersForFirstTime
    TIMESTAMP = 20210927141434
    MANUAL_RUN = false

    def change
      UpdateVendors.call
    end
  end
end
