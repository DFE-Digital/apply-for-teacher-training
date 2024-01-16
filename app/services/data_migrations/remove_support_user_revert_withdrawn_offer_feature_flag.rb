module DataMigrations
  class RemoveSupportUserRevertWithdrawnOfferFeatureFlag
    TIMESTAMP = 20240115125641
    MANUAL_RUN = false

    def change
      Feature.where(name: :support_user_revert_withdrawn_offer).first&.destroy
    end
  end
end
