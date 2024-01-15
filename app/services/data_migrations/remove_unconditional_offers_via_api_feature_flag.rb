module DataMigrations
  class RemoveUnconditionalOffersViaAPIFeatureFlag
    TIMESTAMP = 20240111203308
    MANUAL_RUN = false

    def change
      Feature.where(name: :unconditional_offers_via_api).first&.destroy
    end
  end
end
