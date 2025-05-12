module DataMigrations
  class RemoveUnlockApplicationForEditingFeatureFlag
    TIMESTAMP = 20250217153711
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :unlock_application_for_editing)&.destroy
    end
  end
end
