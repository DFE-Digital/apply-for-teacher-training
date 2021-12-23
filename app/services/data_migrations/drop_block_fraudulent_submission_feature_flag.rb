module DataMigrations
  class DropBlockFraudulentSubmissionFeatureFlag
    TIMESTAMP = 20211223124239
    MANUAL_RUN = false

    def change
      Feature.where(name: :block_fraudulent_submission).first&.destroy
    end
  end
end
