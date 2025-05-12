module DataMigrations
  class RemoveShowReferenceConfidentialityStatusFeatureFlag
    TIMESTAMP = 20250211105529
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :show_reference_confidentiality_status)&.destroy
    end
  end
end
