module DataMigrations
  class RemoveSupportUserReinstateOfferFeatureFlag
    TIMESTAMP = 20240115115953
    MANUAL_RUN = false

    def change
      Feature.where(name: :support_user_reinstate_offer).first&.destroy
    end
  end
end
