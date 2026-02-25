module DataMigrations
  class RemoveServiceInformationBannerFeatureFlag
    TIMESTAMP = 20260225141439
    MANUAL_RUN = false

    def change
      Feature.where(name: 'service_information_banner').delete_all
    end
  end
end
