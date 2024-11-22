module DataMigrations
  class RemoveSampleApplicationsFactoryFeatureFlag
    TIMESTAMP = 20241122140221
    MANUAL_RUN = false

    def change
      Feature.where(name: %i[sample_applications_factory]).delete_all
    end
  end
end
