module DataMigrations
  class RemoveStructuredReasonsForRejectionRedesignFeatureFlag
    TIMESTAMP = 20220428102421
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :structured_reasons_for_rejection_redesign)&.destroy
    end
  end
end
