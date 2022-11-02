module DataMigrations
  class RemoveCandidateReferenceFlowFeatureFlag
    TIMESTAMP = 20221031145204
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :new_references_flow)&.destroy
    end
  end
end
