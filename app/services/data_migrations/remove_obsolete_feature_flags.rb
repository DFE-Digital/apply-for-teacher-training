module DataMigrations
  class RemoveObsoleteFeatureFlags
    TIMESTAMP = 20211109203505
    MANUAL_RUN = false

    def change
      Feature.where.not(name: feature_names).map(&:destroy)
    end

  private

    def feature_names
      FeatureFlag::FEATURES.map(&:first)
    end
  end
end
